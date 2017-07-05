//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// Copyright 2017 - Peter Hedinger
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>
#include <stdlib.h>
#include "neogrid.h"

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
static void show(out port neo, uint8_t colors[])
{
    // Sync port timer
    int port_time;
    neo <: 0 @ port_time;

    // Allow ticks to get from here to the first port drive
    static const int loop_start_ticks = 125;
    port_time += loop_start_ticks;

    for (uint32_t index = 0; index < NUM_COLORS; ++index) {
        uint32_t color = colors[index];

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

static uint8_t saturate(int value)
{
    if (value < 0) {
        return 0;
    } else if (value > 255) {
        return 255;
    } else {
        return value;
    }
}

void pixel_update_strip(out port neo, pixel_state_t &pixels)
{
    uint8_t colors[NUM_COLORS];

    for (size_t index = 0; index < sizeof colors; ++index) {
        colors[index] = saturate((pixels.brightness * pixels.values[index]) >> 8);
    }
    show(neo, colors);
}

void pixel_set_pixel_rgb(pixel_state_t &pixels,
        size_t pixel,
        int r, int g, int b)
{
    size_t index = 3*pixel;
    pixels.values[index++] += r;
    pixels.values[index++] += g;
    pixels.values[index]   += b;
}

void pixel_set_row_col_rgb(pixel_state_t &pixels,
        size_t row, size_t col,
        int r, int g, int b)
{
    const int odd_col = col & 0x1;
    if (odd_col) {
        row = (NUM_ROWS - 1) - row;
    }
    const size_t pixel = col * NUM_ROWS + row;
    pixel_set_pixel_rgb(pixels, pixel, r, g, b);
}

void pixel_set_row_rgb(pixel_state_t &pixels, size_t row,
        int r, int g, int b)
{
    for (size_t col = 0; col < NUM_COLS; ++col) {
        pixel_set_row_col_rgb(pixels, row, col, r, g, b);
    }
}

void pixel_set_col_rgb(pixel_state_t &pixels, size_t col,
        int r, int g, int b)
{
    for (size_t row = 0; row < NUM_ROWS; ++row) {
        pixel_set_row_col_rgb(pixels, row, col, r, g, b);
    }
}

void pixel_set_rgb(pixel_state_t &pixels,
        int r, int g, int b)
{
    for (size_t row = 0; row < NUM_ROWS; ++row) {
        pixel_set_row_rgb(pixels, row, r, g, b);
    }
}

