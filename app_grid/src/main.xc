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
#include "neogrid.h"

out port p = XS1_PORT_1A;

#define MILLISECONDS_TICKS 100000

typedef enum sweep_action_t {
    SWEEP_UP_DOWN,
    SWEEP_LEFT_RIGHT,
    WALK_OUT_BACK,
} sweep_action_t;

typedef struct sweep_state_t {
    sweep_action_t type;
    int pos;
    int dir_speed;
    uint8_t r;
    uint8_t g;
    uint8_t b;
} sweep_state_t;

static void apply_sweep(pixel_state_t &pixels, sweep_state_t &s)
{
    switch (s.type) {
        case SWEEP_UP_DOWN:
            pixel_set_row_rgb(pixels, s.pos, s.r, s.g, s.b);
            s.pos += s.dir_speed;
            if (s.pos >= NUM_ROWS) {
                s.pos = 0;
            } else if (s.pos < 0) {
                s.pos = NUM_ROWS - 1;
            }
            break;

        case SWEEP_LEFT_RIGHT:
            pixel_set_col_rgb(pixels, s.pos, s.r, s.g, s.b);
            s.pos += s.dir_speed;
            if (s.pos >= NUM_COLS) {
                s.pos = 0;
            } else if (s.pos < 0) {
                s.pos = NUM_COLS - 1;
            }
            break;

        case WALK_OUT_BACK:
            for (size_t pixel = 0; pixel < s.pos; ++pixel) {
                pixel_set_pixel_rgb(pixels, pixel, s.r, s.g, s.b);
            }
            s.pos += s.dir_speed;
            if (s.pos >= NUM_PIXELS) {
                s.pos = 0;
            } else if (s.pos <= 0) {
                s.pos = NUM_PIXELS;
            }
            break;
    }
}

void pattern_task(out port neo)
{
    pixel_state_t pixels = {256, {0}};

    sweep_state_t sweeps[] = {
        {SWEEP_UP_DOWN, 0, 1, 0xff, 0x00, 0x00},
        {SWEEP_LEFT_RIGHT, 0, 2, 0x00, 0xff, 0x00},
        {WALK_OUT_BACK, 0, 1, 0x00, 0x00, 0xff},
    };

    const size_t num_sweeps = sizeof(sweeps) / sizeof(sweeps[0]);

    timer tmr;
    int time = 0;
    tmr :> time;
    while(1) {
        memset(&pixels.values, 0, sizeof(pixels.values));

        for (size_t i = 0; i < num_sweeps; ++i) {
            apply_sweep(pixels, sweeps[i]);
        }

        tmr when timerafter(time) :> void;
        pixel_update_strip(neo, pixels);

        time += 100 * MILLISECONDS_TICKS;
    }
}

int main() {

    par {
      pattern_task(p);
    }

    return 0;
}

