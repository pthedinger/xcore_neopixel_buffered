//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// Copyright 2017 - Peter Hedinger
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>
#include <stdlib.h>
#include "neogrid.h"

static uint8_t brightness_lut[256] = {
      0,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   2,   2,   2,   2,   2,   2,   2,   2,   3,   3,   3,   3,   3,   4,   4,
      4,   4,   4,   5,   5,   5,   5,   6,   6,   6,   6,   7,   7,   7,   7,   8,
      8,   8,   9,   9,   9,  10,  10,  10,  11,  11,  12,  12,  12,  13,  13,  14,
     14,  15,  15,  15,  16,  16,  17,  17,  18,  18,  19,  19,  20,  20,  21,  22,
     22,  23,  23,  24,  25,  25,  26,  26,  27,  28,  28,  29,  30,  30,  31,  32,
     33,  33,  34,  35,  36,  36,  37,  38,  39,  40,  40,  41,  42,  43,  44,  45,
     46,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,
     61,  62,  63,  64,  65,  67,  68,  69,  70,  71,  72,  73,  75,  76,  77,  78,
     80,  81,  82,  83,  85,  86,  87,  89,  90,  91,  93,  94,  95,  97,  98,  99,
    101, 102, 104, 105, 107, 108, 110, 111, 113, 114, 116, 117, 119, 121, 122, 124,
    125, 127, 129, 130, 132, 134, 135, 137, 139, 141, 142, 144, 146, 148, 150, 151,
    153, 155, 157, 159, 161, 163, 165, 166, 168, 170, 172, 174, 176, 178, 180, 182,
    184, 186, 189, 191, 193, 195, 197, 199, 201, 204, 206, 208, 210, 212, 215, 217,
    219, 221, 224, 226, 228, 231, 233, 235, 238, 240, 243, 245, 248, 250, 253, 255
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
static void show(out port neo, grid_state_t &grid)
{
    unsafe {
        // Sync port timer
        int port_time;
        neo <: 0 @ port_time;

        // Allow ticks to get from here to the first port drive
        static const int loop_start_ticks = 125;
        port_time += loop_start_ticks;

        const size_t num_colors = grid_num_colors(&grid);
        for (size_t index = 0; index < num_colors; ++index) {
            uint32_t color = grid.saturated_colors[index];

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

void pixel_update_strip(out port neo, grid_state_t &grid)
{
    const size_t num_colors = grid_num_colors(&grid);
    for (size_t index = 0; index < num_colors; ++index) {
        unsafe {
            uint8_t color = saturate((grid.brightness * grid.colors[index]) >> 8);

            // Use a lookup table to scale the color as LEDs have very non-linear
            // brightness
            grid.saturated_colors[index] = brightness_lut[color];
        }
    }
    show(neo, grid);
}

