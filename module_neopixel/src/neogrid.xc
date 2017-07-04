//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// Copyright 2017 - Peter Hedinger
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>
#include <stdlib.h>
#include "neogrid.h"

void grid_set_row_col_rgb(interface neopixel_if client strip,
        uint32_t row, uint32_t col,
        uint8_t r, uint8_t g, uint8_t b)
{
    const int odd_col = col & 0x1;
    if (odd_col) {
        row = (NUM_ROWS - 1) - row;
    }
    const uint32_t pixel = col * NUM_ROWS + row;
    strip.setPixelColorRGB(pixel, r, g, b);
}

void grid_set_row_rgb(interface neopixel_if client strip, uint32_t row,
        uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t col = 0; col < NUM_COLS; ++col) {
        grid_set_row_col_rgb(strip, row, col, r, g, b);
    }
}

void grid_set_col_rgb(interface neopixel_if client strip, uint32_t col,
        uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t row = 0; row < NUM_ROWS; ++row) {
        grid_set_row_col_rgb(strip, row, col, r, g, b);
    }
}

void grid_set_rgb(interface neopixel_if client strip,
        uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t row = 0; row < NUM_ROWS; ++row) {
        grid_set_row_rgb(strip, row, r, g, b);
    }
}

void grid_sweep_left_rgb(interface neopixel_if client strip, int delay_ms,
        uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t col = 0; col < NUM_COLS; ++col) {
        grid_set_col_rgb(strip, col, r, g, b);
        strip.show();
        delay_milliseconds(delay_ms);
    }
}

void grid_sweep_right_rgb(interface neopixel_if client strip, int delay_ms,
        uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t col = NUM_COLS; col > 0; --col) {
        grid_set_col_rgb(strip, col - 1, r, g, b);
        strip.show();
        delay_milliseconds(delay_ms);
    }
}

void grid_sweep_up_rgb(interface neopixel_if client strip, int delay_ms,
        uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t row = NUM_ROWS; row > 0; --row) {
        grid_set_row_rgb(strip, row, r, g, b);
        strip.show();
        delay_milliseconds(delay_ms);
    }
}

void grid_sweep_down_rgb(interface neopixel_if client strip, int delay_ms,
        uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t row = 0; row < NUM_ROWS; ++row) {
        grid_set_row_rgb(strip, row, r, g, b);
        strip.show();
        delay_milliseconds(delay_ms);
    }
}

void grid_walk_to_rgb(interface neopixel_if client strip, int delay_ms,
        uint8_t r, uint8_t g, uint8_t b)
{
    uint32_t length = strip.numPixels();
    for (uint32_t pixel = 0; pixel < length; ++pixel) {
        strip.setPixelColorRGB(pixel, r, g, b);
        strip.show();
        delay_milliseconds(delay_ms);
    }
}

void grid_walk_back_rgb(interface neopixel_if client strip, int delay_ms,
        uint8_t r, uint8_t g, uint8_t b)
{
    uint32_t length = strip.numPixels();
    for (uint32_t pixel = length; pixel > 0; --pixel) {
        strip.setPixelColorRGB(pixel - 1, r, g, b);
        strip.show();
        delay_milliseconds(delay_ms);
    }
}
