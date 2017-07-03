//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// Copyright 2017 - Peter Hedinger
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <print.h>
#include "neopixel.h"

out port p = XS1_PORT_1A;

#define NUM_ROWS 5
#define NUM_COLS 10

// Allow a percision of 10 in each gap between pixels
#define MAX_Y (((NUM_ROWS) - 1) * 10)

#define PER_PIXEL_GAP (MAX_Y / (NUM_ROWS-1))

// A pre-computed table with sine values
#define SINE_TABLE_SIZE 100
const uint32_t sine_table[SINE_TABLE_SIZE] = {
     20, 21, 22, 23, 24, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 36, 37, 38, 38,
     39, 39, 39, 39, 39, 40, 39, 39, 39, 39, 39, 38, 38, 37, 36, 36, 35, 34, 33, 32,
     31, 30, 29, 28, 27, 26, 24, 23, 22, 21, 20, 18, 17, 16, 15, 13, 12, 11, 10,  9,
      8,  7,  6,  5,  4,  3,  3,  2,  1,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
      0,  1,  1,  2,  3,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 15, 16, 17, 18
};

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

void interleave(interface neopixel_if client strip, uint32_t col, uint32_t pos, uint8_t r, uint8_t g, uint8_t b)
{

    set_col_rgb(strip, col, 0, 0, 0);
    int row = pos / PER_PIXEL_GAP;
    int remainder = pos - (row * PER_PIXEL_GAP);

    if (remainder == 0) {
        set_row_col_rgb(strip, row, col, r, g, b);

    } else {
        uint32_t scale1 = (100*(PER_PIXEL_GAP - remainder)) / PER_PIXEL_GAP;
        uint32_t scale2 = 100 - scale1;

        // Divide the color by 2 as the brightness scaling is not very linear
        scale1 /= 2;
        scale2 /= 2;

        set_row_col_rgb(strip, row, col, (scale1*r)/100, (scale1*g)/100, (scale1*b)/100);
        set_row_col_rgb(strip, row+1, col, (scale2*r)/100, (scale2*g)/100, (scale2*b)/100);
    }
}

void set_rgb(interface neopixel_if client strip, uint8_t r, uint8_t g, uint8_t b)
{
    for (uint32_t row = 0; row < NUM_ROWS; ++row) {
        set_row_rgb(strip, row, r, g, b);
    }
}

void sine(interface neopixel_if client strip, int delay_ms, uint32_t n_iters, int dir,
          uint8_t r, uint8_t g, uint8_t b)
{
    for (int iter = 0; iter < n_iters; ++iter) {
        for (uint32_t col = 0; col < NUM_COLS; ++col) {
            const uint32_t index = (col * (SINE_TABLE_SIZE/NUM_COLS) + (iter * dir)) % SINE_TABLE_SIZE;
            interleave(strip, col, sine_table[index], r, g, b);
        }
        strip.show();
        delay_milliseconds(10);
    }
}

void pattern_task(uint32_t taskID, interface neopixel_if client strip)
{
    set_rgb(strip, 0, 0, 0);

    while(1) {
       sine(strip, 10, 10*SINE_TABLE_SIZE,  1, 0xff, 0xff, 0xff); 
       sine(strip, 10, 10*SINE_TABLE_SIZE, -1, 0xff, 0xff, 0xff); 
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

