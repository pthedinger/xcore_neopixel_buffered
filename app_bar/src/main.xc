//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// Copyright 2020 - Peter Hedinger
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "debug_print.h"
#include "neogrid.h"
#include "random.h"

#define NUM_ROWS   10
#define NUM_COLS   10

out port p = XS1_PORT_1A;

// Pre-compute num_colors in order to work around the fact that the
// compiler won't allow a structure to be declared as an expression
#define GRID(cols, rows) (cols), (rows), (3*(cols)*(rows))

void dim(out port neo, grid_state_t &grid, int &time) {
    timer tmr;
    while (grid.brightness != 0) {
        grid.brightness -= 1;
        tmr when timerafter(time) :> void;
        pixel_update_strip(neo, grid);
        time += 5 * MILLISECONDS_TICKS;
    }
    tmr when timerafter(time) :> void;
    pixel_update_strip(neo, grid);
    time += 5 * MILLISECONDS_TICKS;
}

void brighten(out port neo, grid_state_t &grid, int &time) {
    timer tmr;
    while (grid.brightness != 256) {
        grid.brightness += 1;
        tmr when timerafter(time) :> void;
        pixel_update_strip(neo, grid);
        time += 5 * MILLISECONDS_TICKS;
    }
    tmr when timerafter(time) :> void;
    pixel_update_strip(neo, grid);
    time += 5 * MILLISECONDS_TICKS;
}

#define NUM_COLORS 2
static void pattern_task(out port neo,
        static const size_t num_cols,
        static const size_t num_rows,
        static const size_t num_colors)
{
    random_generator_t rand = random_create_generator_from_hw_seed();

    int cols[NUM_COLORS][3] = {
        { 220,  50,  20 }, // Orange
        {   0, 255,   0 }, // Green
        { 255, 255, 255 }, // White
    };

    int colors[num_colors] = {0};
    uint8_t saturated_colors[num_colors] = {0};
    grid_state_t grid;
    grid_init(&grid, num_cols, 8, num_rows, 8, 256, colors, saturated_colors);

    timer tmr;
    int time = 0;
    tmr :> time;

    while(1) {
        size_t num_repeats = random_get_random_number(rand) % 3;

        for (int i = 0; i < num_repeats + 1; ++i) {
            size_t c = random_get_random_number(rand) % NUM_COLORS;

            grid_reset_colors(&grid);
            pixel_set_rgb(&grid, cols[c][0], cols[c][1], cols[c][2]);

            brighten(neo, grid, time);
            time += 2000 * MILLISECONDS_TICKS;
            dim(neo, grid, time);
        }

        for (int i = 0; i < 1; ++i) {
            size_t group = random_get_random_number(rand) % 10;
            size_t c = random_get_random_number(rand) % NUM_COLORS;

            grid_reset_colors(&grid);
            for (int pixel = 0; pixel < 10; ++pixel) {
                pixel_set_pixel_rgb(&grid, (group * 10) + pixel, cols[c][0], cols[c][1], cols[c][2]);
            }

            brighten(neo, grid, time);
            tmr when timerafter(time) :> void;
            pixel_update_strip(neo, grid);
            time += 500 * MILLISECONDS_TICKS;
            dim(neo, grid, time);
        }
    }
}

int main() {
    par {
      pattern_task(p, GRID(10, 10));
    }

    return 0;
}

