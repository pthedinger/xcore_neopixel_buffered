//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// Copyright 2017 - Peter Hedinger
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "debug_print.h"
#include "neogrid.h"

#define TIMING 0
#define VERBOSE 0

out port p = XS1_PORT_1A;

typedef struct sine_state_t {
    int pos;
    int dir_speed;
    int refresh_divider;
    int divide_count;
    uint8_t r;
    uint8_t g;
    uint8_t b;
} sine_state_t;

#define SINE_TABLE_SIZE 256
const uint16_t sine_table[SINE_TABLE_SIZE] = {
    1152, 1180, 1208, 1236, 1264, 1293, 1321, 1348,
    1376, 1404, 1431, 1459, 1486, 1513, 1540, 1566,
    1592, 1618, 1644, 1669, 1695, 1719, 1744, 1768,
    1792, 1815, 1838, 1860, 1882, 1904, 1925, 1946,
    1966, 1986, 2005, 2024, 2042, 2060, 2077, 2093,
    2109, 2125, 2140, 2154, 2167, 2180, 2193, 2205,
    2216, 2226, 2236, 2245, 2254, 2262, 2269, 2276,
    2281, 2287, 2291, 2295, 2298, 2300, 2302, 2303,
    2304, 2303, 2302, 2300, 2298, 2295, 2291, 2287,
    2281, 2276, 2269, 2262, 2254, 2245, 2236, 2226,
    2216, 2205, 2193, 2180, 2167, 2154, 2140, 2125,
    2109, 2093, 2077, 2060, 2042, 2024, 2005, 1986,
    1966, 1946, 1925, 1904, 1882, 1860, 1838, 1815,
    1792, 1768, 1744, 1719, 1695, 1669, 1644, 1618,
    1592, 1566, 1540, 1513, 1486, 1459, 1431, 1404,
    1376, 1348, 1321, 1293, 1264, 1236, 1208, 1180,
    1152, 1123, 1095, 1067, 1039, 1010,  982,  955,
     927,  899,  872,  844,  817,  790,  763,  737,
     711,  685,  659,  634,  608,  584,  559,  535,
     511,  488,  465,  443,  421,  399,  378,  357,
     337,  317,  298,  279,  261,  243,  226,  210,
     194,  178,  163,  149,  136,  123,  110,   98,
      87,   77,   67,   58,   49,   41,   34,   27,
      22,   16,   12,    8,    5,    3,    1,    0,
       0,    0,    1,    3,    5,    8,   12,   16,
      22,   27,   34,   41,   49,   58,   67,   77,
      87,   98,  110,  123,  136,  149,  163,  178,
     194,  210,  226,  243,  261,  279,  298,  317,
     337,  357,  378,  399,  421,  443,  465,  488,
     511,  535,  559,  584,  608,  634,  659,  685,
     711,  737,  763,  790,  817,  844,  872,  899,
     927,  955,  982, 1010, 1039, 1067, 1095, 1123
};

static void apply_sine(grid_state_t &grid, sine_state_t &s)
{
    for (size_t col = 0; col < grid.num_cols; ++col) {
        // Start with the colums spread out across the sine wave
        size_t index = (col * SINE_TABLE_SIZE)/grid.num_cols;
        index += s.pos;

        // Compute an index in the table
        index %= SINE_TABLE_SIZE;

        size_t row = 0;
        size_t scale1 = 0;
        size_t scale2 = 0;
        linear_interpolation(sine_table[index], grid.points_per_gap_y_log2, &row, &scale1, &scale2);
        pixel_set_col_row_rgb(&grid, col, row,
            (scale1*s.r) >> SCALE_FACTOR_LOG2,
            (scale1*s.g) >> SCALE_FACTOR_LOG2,
            (scale1*s.b) >> SCALE_FACTOR_LOG2);
        if (scale2) {
            pixel_set_row_col_rgb(&grid, row+1, col,
                (scale2*s.r) >> SCALE_FACTOR_LOG2,
                (scale2*s.g) >> SCALE_FACTOR_LOG2,
                (scale2*s.b) >> SCALE_FACTOR_LOG2);
        }
    }

    // Allow the sine wave to move at a fraction of the refresh speed
    if (s.divide_count) {
        s.divide_count -= 1;
    } else {
        s.pos += s.dir_speed;
        s.divide_count = s.refresh_divider;
    }
}

// Pre-compute num_colors in order to work around the fact that the
// compiler won't allow a structure to be declared as an expression
#define GRID(cols, rows) (cols), (rows), (3*(cols)*(rows))

static void pattern_task(out port neo,
        static const size_t num_cols,
        static const size_t num_rows,
        static const size_t num_colors)
{
    int colors[num_colors] = {0};
    uint8_t saturated_colors[num_colors] = {0};
    grid_state_t grid;
    grid_init(&grid, num_cols, 8, num_rows, 8, 256, colors, saturated_colors);

    #if TIMING
    timer perf_tmr;
    int start_time = 0, end_time = 0;
    perf_tmr :> start_time;
    #endif

    sine_state_t sines[] = {
        // {0, 1, 3, 0, 0x00, 0x00, 0xff},
        // {0, 2, 3, 0, 0x00, 0xff, 0x00},
        // {0, 3, 3, 0, 0xff, 0x00, 0x00},
        {0, 2, 1, 0, 0xff, 0xff, 0xff},
    };

    // Allow the brightness to go down & up
    int brightness_delta = -1;

    const size_t num_sines = sizeof(sines) / sizeof(sines[0]);

    timer tmr;
    int time = 0;
    tmr :> time;
    for (size_t iter = 0; ; ++iter) {
        grid_reset_colors(&grid);

        // Render the sines
        for (size_t i = 0; i < num_sines; ++i) {
            apply_sine(grid, sines[i]);
        }

        #if TIMING
        perf_tmr :> end_time;
        debug_printf("Loop %d\n", end_time - start_time);
        #endif

        tmr when timerafter(time) :> void;
        pixel_update_strip(neo, grid);
        tmr :> time;

        #if TIMING
        perf_tmr :> start_time;
        #endif

        // Refresh rate limited to 500 frames per second
        time += MILLISECONDS_TICKS/10;

        if ((iter & 0x7) == 0) {
            grid.brightness += brightness_delta;
            // Never let it go completely black (<=1)
            if (grid.brightness <= 1) {
                brightness_delta = 1;
                grid.brightness = 1;
            } else if (grid.brightness >= 256) {
                brightness_delta = -1;
                grid.brightness = 256;
            }
        }
    }
}

int main() {
    par {
      pattern_task(p, GRID(10, 10));
    }

    return 0;
}

