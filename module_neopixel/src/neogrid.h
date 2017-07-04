//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// by Peter Hedinger
//
#ifndef __neogrid_h__
#define __neogrid_h__

#include <stddef.h>
#include "neopixel.h"

#ifndef NUM_ROWS
#define NUM_ROWS 5
#endif

#ifndef NUM_COLS
#define NUM_COLS 10
#endif

void grid_set_row_col_rgb(interface neopixel_if client strip,
        uint32_t row, uint32_t col,
        uint8_t r, uint8_t g, uint8_t b);

void grid_set_row_rgb(interface neopixel_if client strip, uint32_t row,
        uint8_t r, uint8_t g, uint8_t b);

void grid_set_col_rgb(interface neopixel_if client strip, uint32_t col,
        uint8_t r, uint8_t g, uint8_t b);

void grid_set_rgb(interface neopixel_if client strip,
        uint8_t r, uint8_t g, uint8_t b);

void grid_sweep_left_rgb(interface neopixel_if client strip, int delay_ms,
        uint8_t r, uint8_t g, uint8_t b);

void grid_sweep_right_rgb(interface neopixel_if client strip, int delay_ms,
        uint8_t r, uint8_t g, uint8_t b);

void grid_sweep_up_rgb(interface neopixel_if client strip, int delay_ms,
        uint8_t r, uint8_t g, uint8_t b);

void grid_sweep_down_rgb(interface neopixel_if client strip, int delay_ms,
        uint8_t r, uint8_t g, uint8_t b);

void grid_walk_to_rgb(interface neopixel_if client strip, int delay_ms,
        uint8_t r, uint8_t g, uint8_t b);

void grid_walk_back_rgb(interface neopixel_if client strip, int delay_ms,
        uint8_t r, uint8_t g, uint8_t b);

#endif // __neogrid_h__