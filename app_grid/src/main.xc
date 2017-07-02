//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// Copyright 2017 - Peter Hedinger
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include "neopixel.h"

out port p = XS1_PORT_1A;

#define NUM_ROWS 5
#define NUM_COLS 10

void set_row_col_rgb(interface neopixel_if client strip,
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

void set_row_rgb(interface neopixel_if client strip, uint32_t row, uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t col = 0; col < NUM_COLS; ++col) {
        set_row_col_rgb(strip, row, col, r, g, b);
    }
}

void set_col_rgb(interface neopixel_if client strip, uint32_t col, uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t row = 0; row < NUM_ROWS; ++row) {
        set_row_col_rgb(strip, row, col, r, g, b);
    }
}

void set_rgb(interface neopixel_if client strip, uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t row = 0; row < NUM_ROWS; ++row) {
        set_row_rgb(strip, row, r, g, b);
    }
}

void sweep_left_rgb(interface neopixel_if client strip, int delay_ms,
    uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t col = 0; col < NUM_COLS; ++col) {
        set_col_rgb(strip, col, r, g, b);
        strip.show();
        delay_milliseconds(delay_ms);
    }
}

void sweep_right_rgb(interface neopixel_if client strip, int delay_ms,
    uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t col = NUM_COLS; col > 0; --col) {
        set_col_rgb(strip, col - 1, r, g, b);
        strip.show();
        delay_milliseconds(delay_ms);
    }
}

void sweep_up_rgb(interface neopixel_if client strip, int delay_ms,
    uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t row = NUM_ROWS; row > 0; --row) {
        set_row_rgb(strip, row, r, g, b);
        strip.show();
        delay_milliseconds(delay_ms);
    }
}

void sweep_down_rgb(interface neopixel_if client strip, int delay_ms,
    uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t row = 0; row < NUM_ROWS; ++row) {
        set_row_rgb(strip, row, r, g, b);
        strip.show();
        delay_milliseconds(delay_ms);
    }
}

void walk_to_rgb(interface neopixel_if client strip, int delay_ms,
    uint8_t r, uint8_t g, uint8_t b)
{
    uint32_t length = strip.numPixels();
    for (uint32_t pixel = 0; pixel < length; ++pixel) {
        strip.setPixelColorRGB(pixel, r, g, b);
        strip.show();
        delay_milliseconds(delay_ms);
    }
}

void walk_back_rgb(interface neopixel_if client strip, int delay_ms,
    uint8_t r, uint8_t g, uint8_t b)
{
    uint32_t length = strip.numPixels();
    for (uint32_t pixel = length; pixel > 0; --pixel) {
        strip.setPixelColorRGB(pixel - 1, r, g, b);
        strip.show();
        delay_milliseconds(delay_ms);
    }
}

void pattern_task(uint32_t taskID, interface neopixel_if client strip)
{
    set_rgb(strip, 0, 0, 0);

    for (uint32_t iter = 0; ; ++iter) {
        for (int delay_ms = 10; delay_ms > 0; --delay_ms) {
            sweep_up_rgb(strip, delay_ms * 10, 0xff, 0, 0);
            sweep_down_rgb(strip, delay_ms * 10, 0, 0xff, 0);

            sweep_left_rgb(strip, delay_ms * 5, 0xff, 0, 0);
            sweep_right_rgb(strip, delay_ms * 5, 0, 0xff, 0);

            walk_to_rgb(strip, 25, 0, 0, 0xff);
            walk_back_rgb(strip, 25, 0, 0, 0);
        }
    }
}


int main() {
    interface neopixel_if neopixel_strip[8];

    par {
      neopixel_task(p, PIXELS(50), NEO_RGB, neopixel_strip[0]);
      pattern_task(0, neopixel_strip[0] );
    }

    return 0;
}

