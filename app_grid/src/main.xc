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

out port p = XS1_PORT_1A;

typedef enum sweep_action_t {
    SWEEP_UP_DOWN,
    SWEEP_LEFT_RIGHT,
    WALK_OUT_BACK,
} sweep_action_t;

typedef struct sweep_state_t {
    sweep_action_t type;
    int pos;
    int dir_speed;
    int bounce;
    int refresh_divider;
    int divide_count;
    uint8_t r;
    uint8_t g;
    uint8_t b;
} sweep_state_t;

static void apply_sweep(grid_state_t &grid, sweep_state_t &s)
{
    int do_move = 0;

    // Allow the sine wave to move at a fraction of the refresh speed
    s.divide_count -= 1;
    if (s.divide_count <= 0) {
        s.divide_count = s.refresh_divider;
        do_move = 1;
    }

    switch (s.type) {
        case SWEEP_UP_DOWN:
            pixel_interpolate_row_rgb(&grid, s.pos, s.r, s.g, s.b);

            if (do_move) {
                s.pos += s.dir_speed;

                // A position of max_y is valid
                if (s.pos >= grid.max_y) {
                    if (s.bounce) {
                        s.dir_speed = -s.dir_speed;
                        s.pos = grid.max_y;
                    } else {
                        s.pos = 0;
                    }
                } else if (s.pos <= 0) {
                    if (s.bounce) {
                        s.dir_speed = -s.dir_speed;
                        s.pos = 0;
                    } else {
                        s.pos = grid.max_y;
                    }
                }
            }
            break;

        case SWEEP_LEFT_RIGHT:
            pixel_interpolate_col_rgb(&grid, s.pos, s.r, s.g, s.b);

            if (do_move) {
                s.pos += s.dir_speed;

                // A position of max_x is valid
                if (s.pos >= grid.max_x) {
                    if (s.bounce) {
                        s.dir_speed = -s.dir_speed;
                        s.pos = grid.max_x;
                    } else {
                        s.pos = 0;
                    }
                } else if (s.pos <= 0) {
                    if (s.bounce) {
                        s.dir_speed = -s.dir_speed;
                        s.pos = 0;
                    } else {
                        s.pos = grid.max_x;
                    }
                }
            }
            break;

        case WALK_OUT_BACK:
            for (size_t pixel = 0; pixel < s.pos; ++pixel) {
                pixel_set_pixel_rgb(&grid, pixel, s.r, s.g, s.b);
            }

            if (do_move) {
                s.pos += s.dir_speed;

                const size_t num_pixels = grid.num_rows * grid.num_cols;
                if (s.pos >= num_pixels) {
                    if (s.bounce) {
                        s.dir_speed = -s.dir_speed;
                        s.pos = num_pixels;
                    } else {
                        s.pos = 0;
                    }
                } else if (s.pos <= 0) {
                    if (s.bounce) {
                        s.dir_speed = -s.dir_speed;
                        s.pos = 0;
                    } else {
                        s.pos = num_pixels;
                    }
                }
            }
            break;
    }
}

// Pre-compute num_colors in order to work around the fact that the
// compiler won't allow a structure to be declared as an expression
#define GRID(cols, rows) (cols), (rows), (3*(cols)*(rows))

void pattern_task(out port neo,
        static const size_t num_cols,
        static const size_t num_rows,
        static const size_t num_colors)
{
    int colors[num_colors] = {0};
    uint8_t saturated_colors[num_colors] = {0};
    grid_state_t grid;
    grid_init(&grid, num_cols, 8, num_rows, 8, 256, colors, saturated_colors);

    sweep_state_t sweeps[] = {
        {SWEEP_UP_DOWN,    0, 1, 1, 1, 0, 0xff, 0x00, 0x00},
        {SWEEP_UP_DOWN,    0, 3, 1, 1, 0, 0x00, 0xff, 0x00},
        {SWEEP_UP_DOWN,    0, 5, 1, 1, 0, 0x00, 0x00, 0xff},
        {SWEEP_LEFT_RIGHT, 0, 1, 1, 1, 0, 0xff, 0x00, 0x00},
        {SWEEP_LEFT_RIGHT, 0, 3, 1, 1, 0, 0x00, 0xff, 0x00},
        {SWEEP_LEFT_RIGHT, 0, 5, 1, 1, 0, 0x00, 0x00, 0xff},
        // {WALK_OUT_BACK,    0, 1, 1, 10, 0, 0xff, 0xff, 0x00},
        // {WALK_OUT_BACK,    0, 2, 1,  1, 0, 0x5, 0x5, 0x5},
    };

    const size_t num_sweeps = sizeof(sweeps) / sizeof(sweeps[0]);

    timer tmr;
    int time = 0;
    tmr :> time;
    while(1) {
        grid_reset_colors(&grid);

        for (size_t i = 0; i < num_sweeps; ++i) {
            apply_sweep(grid, sweeps[i]);
        }

        tmr when timerafter(time) :> void;
        pixel_update_strip(neo, grid);
        tmr :> time;

        time += MILLISECONDS_TICKS/ 10;
    }
}

int main() {
    par {
      pattern_task(p, GRID(10, 10));
    }

    return 0;
}

