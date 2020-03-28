//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// Copyright 2020 - Peter Hedinger
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "debug_print.h"
#include "neogrid.h"

#define NUM_ROWS   10
#define NUM_COLS   10

#include "letters.h"
#include "image.h"

out port p = XS1_PORT_1A;

// Pre-compute num_colors in order to work around the fact that the
// compiler won't allow a structure to be declared as an expression
#define GRID(cols, rows) (cols), (rows), (3*(cols)*(rows))

static void pattern_task(out port neo,
        static const size_t num_cols,
        static const size_t num_rows,
        static const size_t num_colors)
{
    int colors[num_colors] = {0};
    uint8_t saturated_colors[num_colors] = {0};
    grid_state_t grid;
    grid_init(&grid, num_cols, 8, num_rows, 8, 256, colors, saturated_colors);

    timer tmr;
    int time = 0;
    tmr :> time;
    for (size_t iter = 0; ; ++iter) {
        // for (char c = 'A'; c <= 'Z'; ++c) {
        //     grid_reset_colors(&grid);

        //     render_letter(grid, c, 0xff, 0xff, 0xff);

        //     tmr when timerafter(time) :> void;
        //     pixel_update_strip(neo, grid);
        //     tmr :> time;

        //     time += 1000 * MILLISECONDS_TICKS;
        // }
        render_text(neo, grid, " THANK YOU NHS", 0xff, 0xff, 0xff, time);

        time += 2000 * MILLISECONDS_TICKS;

        for (size_t index = 0; index < NUM_IMAGES; ++index) {
            size_t next_image = index + 1;
            if (next_image >= NUM_IMAGES) {
                next_image = 0;
            }

            transition_image(neo, grid, images[index], images[next_image], time);

            // tmr when timerafter(time) :> void;
            // pixel_update_strip(neo, grid);
            // tmr :> time;

            time += 2000 * MILLISECONDS_TICKS;
        }


        // for (size_t index = 0; index < NUM_IMAGES; ++index) {
        //     grid_reset_colors(&grid);

        //     render_image(grid, images[index]);

        //     tmr when timerafter(time) :> void;
        //     pixel_update_strip(neo, grid);
        //     tmr :> time;

        //     time += 3000 * MILLISECONDS_TICKS;
        // }
    }
}

int main() {
    par {
      pattern_task(p, GRID(10, 10));
    }

    return 0;
}

