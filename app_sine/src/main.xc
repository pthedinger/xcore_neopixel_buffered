//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// Copyright 2017 - Peter Hedinger
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include "debug_print.h"
#include "neogrid.h"

#define MILLISECONDS_TICKS 100000
#define NUM_COLORS (3*NUM_ROWS*NUM_COLS)

out port p = XS1_PORT_1A;

typedef struct sine_state_t {
    int pos;
    int dir_speed;
    uint8_t r;
    uint8_t g;
    uint8_t b;
} sine_state_t;

typedef struct pixel_state_t {
    int values[NUM_COLORS];
} pixel_state_t;

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

static inline void drive_0(out port neo, int &port_time)
{
    neo @ port_time <: 1;
    port_time += T0H_TICKS;
    neo @ port_time <: 0;
    port_time += T0L_TICKS;
}

static inline void drive_1(out port neo, int &port_time)
{
    neo @ port_time <: 1;
    port_time += T1H_TICKS;
    neo @ port_time <: 0;
    port_time += T1L_TICKS;
}

#pragma unsafe arrays
void show(out port neo, uint8_t colors[])
{
    // Sync port timer
    int port_time;
    neo <: 0 @ port_time;

    // Allow ticks to get from here to the first port drive
    static const int loop_start_ticks = 125;
    port_time += loop_start_ticks;

    for (uint32_t index = 0; index < NUM_COLORS; ++index) {
        uint32_t color = colors[index];
        // if (brightness) {
        //     color = (brightness*color)>>8;
        // }

        uint32_t bit_count = 8;
        while (bit_count--) {
            uint32_t bit = (color & 0x80) ? 1 : 0;
            if (bit) {
                drive_1(neo, port_time);
            } else {
                drive_0(neo, port_time);
            }
            color <<= 1;
        }
    }
    // Hold last pixel
    neo @ port_time <: 0;
}

static uint8_t saturate(int value) {
    if (value < 0) {
        return 0;
    } else if (value > 255) {
        return 255;
    } else {
        return value;
    }
}

void update_strip(out port neo, pixel_state_t &pixels)
{
    uint8_t colors[NUM_COLORS];

    for (size_t index = 0; index < sizeof colors; ++index) {
        colors[index] = saturate(pixels.values[index]);
    }
    show(neo, colors);
}

void set_row_col_rgb(pixel_state_t &pixels,
        size_t row, size_t col,
        int r, int g, int b)
{
    const int odd_col = col & 0x1;
    if (odd_col) {
        row = (NUM_ROWS - 1) - row;
    }
    const size_t pixel = col * NUM_ROWS + row;

    size_t index = 3*pixel;
    pixels.values[index++] += r;
    pixels.values[index++] += g;
    pixels.values[index]   += b;
}

void interleave(pixel_state_t &pixels, size_t col, size_t pos, int r, int g, int b)
{
    size_t row = pos / PER_PIXEL_GAP;
    size_t remainder = pos - (row * PER_PIXEL_GAP);

    if (remainder == 0) {
        set_row_col_rgb(pixels, row, col, r, g, b);

    } else {
        int scale1 = (DIV_FACTOR*(PER_PIXEL_GAP - remainder)) / PER_PIXEL_GAP;
        int scale2 = DIV_FACTOR - scale1;

        // Divide the color by 2 as the brightness scaling is not very linear
        scale1 /= 2;
        scale2 /= 2;

        set_row_col_rgb(pixels, row, col, (scale1*r)/DIV_FACTOR, (scale1*g)/DIV_FACTOR, (scale1*b)/DIV_FACTOR);
        set_row_col_rgb(pixels, row+1, col, (scale2*r)/DIV_FACTOR, (scale2*g)/DIV_FACTOR, (scale2*b)/DIV_FACTOR);
    }
}

void apply_sine(pixel_state_t &pixels, sine_state_t &s, int mult)
{
    for (size_t col = 0; col < NUM_COLS; ++col) {
        // Start with the colums spread out across the sine wave
        size_t index = (col * SINE_TABLE_SIZE)/NUM_COLS;
        index += s.pos;

        // Compute an index in the table
        index %= SINE_TABLE_SIZE;

        interleave(pixels, col, sine_table[index],
            ((int)s.r) * mult, ((int)s.g) * mult, ((int)s.b) * mult);
    }
}

void step_sine(sine_state_t &sine)
{
    sine.pos += sine.dir_speed;
}

void pattern_task(uint32_t taskID, out port neo)
{
    sine_state_t sines[] = {
        // {0, 1, 0xff, 0x00, 0x00},
        // {0, -1, 0x00, 0xff, 0x00},
        {0, 4, 0x00, 0x00, 0xff}
    };

    pixel_state_t pixels = {{0}};

    const size_t num_sines = sizeof(sines) / sizeof(sines[0]);

    timer tmr;
    int time;
    tmr :> time;
    while(1) {
        for (size_t i = 0; i < num_sines; ++i) {
            // Render each sine
            apply_sine(pixels, sines[i], 1);
        }

        tmr when timerafter(time) :> void;
        update_strip(neo, pixels);
        time += 10 * MILLISECONDS_TICKS;

        for (size_t i = 0; i < num_sines; ++i) {
            // Clear the effects of applying the sines
            apply_sine(pixels, sines[i], -1);
        }

        for (size_t i = 0; i < num_sines; ++i) {
            step_sine(sines[i]);
        }
    }
}

int main() {
    par {
      pattern_task(0, p);
    }

    return 0;
}

