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

#define MILLISECONDS_TICKS 100000

out port p = XS1_PORT_1A;

typedef struct sine_state_t {
    int pos;
    int dir_speed;
    uint8_t r;
    uint8_t g;
    uint8_t b;
} sine_state_t;

// #define DIV_FACTOR 100
// #define PER_PIXEL_GAP 10
// #define MAX_Y (((NUM_ROWS) - 1) * PER_PIXEL_GAP)

// // A pre-computed table with sine values
// #define SINE_TABLE_SIZE 100
// const uint8_t sine_table[SINE_TABLE_SIZE] = {
//      20, 21, 22, 23, 24, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 36, 37, 38, 38,
//      39, 39, 39, 39, 39, 40, 39, 39, 39, 39, 39, 38, 38, 37, 36, 36, 35, 34, 33, 32,
//      31, 30, 29, 28, 27, 26, 24, 23, 22, 21, 20, 18, 17, 16, 15, 13, 12, 11, 10,  9,
//       8,  7,  6,  5,  4,  3,  3,  2,  1,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
//       0,  1,  1,  2,  3,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 15, 16, 17, 18
// };
#define PER_PIXEL_GAP 16
#define DIV_FACTOR 256
#define MAX_Y (((NUM_ROWS) - 1) * PER_PIXEL_GAP)

#define SCALE(x) ((x*MAX_Y) / 256)
#define SINE_TABLE_SIZE 256
const uint8_t sine_table[SINE_TABLE_SIZE] = {
    SCALE(127), SCALE(130), SCALE(133), SCALE(136), SCALE(139), SCALE(143), SCALE(146), SCALE(149),
    SCALE(152), SCALE(155), SCALE(158), SCALE(161), SCALE(164), SCALE(167), SCALE(170), SCALE(173),
    SCALE(176), SCALE(179), SCALE(182), SCALE(184), SCALE(187), SCALE(190), SCALE(193), SCALE(195),
    SCALE(198), SCALE(200), SCALE(203), SCALE(205), SCALE(208), SCALE(210), SCALE(213), SCALE(215),
    SCALE(217), SCALE(219), SCALE(221), SCALE(224), SCALE(226), SCALE(228), SCALE(229), SCALE(231),
    SCALE(233), SCALE(235), SCALE(236), SCALE(238), SCALE(239), SCALE(241), SCALE(242), SCALE(244),
    SCALE(245), SCALE(246), SCALE(247), SCALE(248), SCALE(249), SCALE(250), SCALE(251), SCALE(251),
    SCALE(252), SCALE(253), SCALE(253), SCALE(254), SCALE(254), SCALE(254), SCALE(254), SCALE(254),
    SCALE(255), SCALE(254), SCALE(254), SCALE(254), SCALE(254), SCALE(254), SCALE(253), SCALE(253),
    SCALE(252), SCALE(251), SCALE(251), SCALE(250), SCALE(249), SCALE(248), SCALE(247), SCALE(246),
    SCALE(245), SCALE(244), SCALE(242), SCALE(241), SCALE(239), SCALE(238), SCALE(236), SCALE(235),
    SCALE(233), SCALE(231), SCALE(229), SCALE(228), SCALE(226), SCALE(224), SCALE(221), SCALE(219),
    SCALE(217), SCALE(215), SCALE(213), SCALE(210), SCALE(208), SCALE(205), SCALE(203), SCALE(200),
    SCALE(198), SCALE(195), SCALE(193), SCALE(190), SCALE(187), SCALE(184), SCALE(182), SCALE(179),
    SCALE(176), SCALE(173), SCALE(170), SCALE(167), SCALE(164), SCALE(161), SCALE(158), SCALE(155),
    SCALE(152), SCALE(149), SCALE(146), SCALE(143), SCALE(139), SCALE(136), SCALE(133), SCALE(130),
    SCALE(127), SCALE(124), SCALE(121), SCALE(118), SCALE(115), SCALE(111), SCALE(108), SCALE(105),
    SCALE(102), SCALE( 99), SCALE( 96), SCALE( 93), SCALE( 90), SCALE( 87), SCALE( 84), SCALE( 81),
    SCALE( 78), SCALE( 75), SCALE( 72), SCALE( 70), SCALE( 67), SCALE( 64), SCALE( 61), SCALE( 59),
    SCALE( 56), SCALE( 54), SCALE( 51), SCALE( 49), SCALE( 46), SCALE( 44), SCALE( 41), SCALE( 39),
    SCALE( 37), SCALE( 35), SCALE( 33), SCALE( 30), SCALE( 28), SCALE( 26), SCALE( 25), SCALE( 23),
    SCALE( 21), SCALE( 19), SCALE( 18), SCALE( 16), SCALE( 15), SCALE( 13), SCALE( 12), SCALE( 10),
    SCALE(  9), SCALE(  8), SCALE(  7), SCALE(  6), SCALE(  5), SCALE(  4), SCALE(  3), SCALE(  3),
    SCALE(  2), SCALE(  1), SCALE(  1), SCALE(  0), SCALE(  0), SCALE(  0), SCALE(  0), SCALE(  0),
    SCALE(  0), SCALE(  0), SCALE(  0), SCALE(  0), SCALE(  0), SCALE(  0), SCALE(  1), SCALE(  1),
    SCALE(  2), SCALE(  3), SCALE(  3), SCALE(  4), SCALE(  5), SCALE(  6), SCALE(  7), SCALE(  8),
    SCALE(  9), SCALE( 10), SCALE( 12), SCALE( 13), SCALE( 15), SCALE( 16), SCALE( 18), SCALE( 19),
    SCALE( 21), SCALE( 23), SCALE( 25), SCALE( 26), SCALE( 28), SCALE( 30), SCALE( 33), SCALE( 35),
    SCALE( 37), SCALE( 39), SCALE( 41), SCALE( 44), SCALE( 46), SCALE( 49), SCALE( 51), SCALE( 54),
    SCALE( 56), SCALE( 59), SCALE( 61), SCALE( 64), SCALE( 67), SCALE( 70), SCALE( 72), SCALE( 75),
    SCALE( 78), SCALE( 81), SCALE( 84), SCALE( 87), SCALE( 90), SCALE( 93), SCALE( 96), SCALE( 99),
    SCALE(102), SCALE(105), SCALE(108), SCALE(111), SCALE(115), SCALE(118), SCALE(121), SCALE(124)
};

static void interleave(pixel_state_t &pixels, size_t col, size_t pos, int r, int g, int b)
{
    size_t row = pos / PER_PIXEL_GAP;
    size_t remainder = pos - (row * PER_PIXEL_GAP);

    if (remainder == 0) {
        pixel_set_row_col_rgb(pixels, row, col, r, g, b);

    } else {
        int scale1 = (DIV_FACTOR*(PER_PIXEL_GAP - remainder)) / PER_PIXEL_GAP;
        int scale2 = DIV_FACTOR - scale1;

        // Divide the color by 2 as the brightness scaling is not very linear
        scale1 /= 2;
        scale2 /= 2;

        pixel_set_row_col_rgb(pixels, row, col, (scale1*r)/DIV_FACTOR, (scale1*g)/DIV_FACTOR, (scale1*b)/DIV_FACTOR);
        pixel_set_row_col_rgb(pixels, row+1, col, (scale2*r)/DIV_FACTOR, (scale2*g)/DIV_FACTOR, (scale2*b)/DIV_FACTOR);
    }
}

static void apply_sine(pixel_state_t &pixels, sine_state_t &s)
{
    for (size_t col = 0; col < NUM_COLS; ++col) {
        // Start with the colums spread out across the sine wave
        size_t index = (col * SINE_TABLE_SIZE)/NUM_COLS;
        index += s.pos;

        // Compute an index in the table
        index %= SINE_TABLE_SIZE;

        interleave(pixels, col, sine_table[index], s.r, s.g, s.b);
    }
    s.pos += s.dir_speed;
}

static void pattern_task(out port neo)
{
    #if TIMING
    timer perf_tmr;
    int start_time = 0, end_time = 0;
    perf_tmr :> start_time;
    #endif

    sine_state_t sines[] = {
        {0, 1, 0x00, 0x00, 0xff},
        {0, 2, 0x00, 0xff, 0x00},
        {0, 3, 0xff, 0x00, 0x00},
    };

    pixel_state_t pixels = {256, {0}};

    // Allow the brightness to go down & up
    int brightness_delta = -1;

    const size_t num_sines = sizeof(sines) / sizeof(sines[0]);

    timer tmr;
    int time = 0;
    tmr :> time;
    while(1) {
        // Zero the entire pixel array
        memset(&pixels.values, 0, sizeof(pixels.values));

        // Render the sines
        for (size_t i = 0; i < num_sines; ++i) {
            apply_sine(pixels, sines[i]);
        }

        #if TIMING
        perf_tmr :> end_time;
        debug_printf("Loop %d\n", end_time - start_time);
        #endif

        tmr when timerafter(time) :> void;
        pixel_update_strip(neo, pixels);

        #if TIMING
        perf_tmr :> start_time;
        #endif

        time += 10 * MILLISECONDS_TICKS;

        pixels.brightness += brightness_delta;
        if (pixels.brightness <= 0) {
            brightness_delta = 1;
            pixels.brightness = 0;
        } else if (pixels.brightness >= 256) {
            brightness_delta = -1;
            pixels.brightness = 256;
        }
    }
}

int main() {
    par {
      pattern_task(p);
    }

    return 0;
}

