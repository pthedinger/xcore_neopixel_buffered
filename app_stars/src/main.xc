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
#include "random.h"

out port p = XS1_PORT_1A;

typedef struct star_state_t {
    int pos_x;
    int pos_y;
    int brightness;
    int dir_speed;
    int refresh_divider;
    int divide_count;
    int size;
    uint8_t r;
    uint8_t g;
    uint8_t b;
} star_state_t;


static void randomize_star(grid_state_t &grid, star_state_t &s, random_generator_t &rand)
{
    s.pos_x = random_get_random_number(rand) % grid.num_cols;
    s.pos_y = random_get_random_number(rand) % grid.num_rows;

    // Always start it off
    s.brightness = 0;
    // Choosing a random speed of fading (ensuring they don't get stuck off)
    s.dir_speed = (random_get_random_number(rand) & 0x3) + 1;
    s.refresh_divider = (random_get_random_number(rand) & 0x3) + 5;

    int size_choice = random_get_random_number(rand) & 0xff;
    if (size_choice > 250) {
        s.size = 4;
    } else if (size_choice > 230) {
        s.size = 3;
    } else if (size_choice > 200) {
        s.size = 2;
    } else {
        s.size = 1;
    }

    s.r = random_get_random_number(rand);
    s.g = random_get_random_number(rand);
    s.b = random_get_random_number(rand);
}

static void apply_star(grid_state_t &grid, star_state_t &s)
{
    int r = ((int)s.r * s.brightness) >> 8;
    int g = ((int)s.g * s.brightness) >> 8;
    int b = ((int)s.b * s.brightness) >> 8;

    pixel_set_col_row_rgb(&grid, s.pos_x, s.pos_y, r, g, b);
    for (int distance = 1; distance < s.size; ++distance) {
        r = r >> 2;
        g = g >> 2;
        b = b >> 2;
        if (s.pos_x >= distance) {
            pixel_set_col_row_rgb(&grid, s.pos_x-distance, s.pos_y, r, g, b);
        }
        if (s.pos_y >= distance) {
            pixel_set_col_row_rgb(&grid, s.pos_x, s.pos_y-distance, r, g, b);
        }
        if ((s.pos_x + distance) < grid.num_cols) {
            pixel_set_col_row_rgb(&grid, s.pos_x+distance, s.pos_y, r, g, b);
        }
        if ((s.pos_y + distance) < grid.num_rows) {
            pixel_set_col_row_rgb(&grid, s.pos_x, s.pos_y+distance, r, g, b);
        }
    }

    // Allow the sine wave to move at a fraction of the refresh speed
    if (s.divide_count) {
        s.divide_count -= 1;
    } else {
        s.divide_count = s.refresh_divider;

        s.brightness += s.dir_speed;
        if (s.brightness < 0) {
            s.brightness = 0;
            s.dir_speed = -s.dir_speed;
        } else if (s.brightness > 256) {
            s.brightness = 256;
            s.dir_speed = -s.dir_speed;
        }
    }
}

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

    random_generator_t rand = random_create_generator_from_hw_seed();

    star_state_t stars[] = {
        {0, 0, 256, -1, 1, 0, 1, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 1, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 1, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 1, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 1, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 1, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 1, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 1, 0xff, 0xff, 0xff},
    };

    const size_t num_stars = sizeof(stars) / sizeof(stars[0]);

    for (size_t i = 0; i < num_stars; ++i) {
        randomize_star(grid, stars[i], rand);
    }

    int do_move = 0;

    timer tmr;
    int time = 0;
    tmr :> time;
    for (size_t iter = 0; ; ++iter) {
        grid_reset_colors(&grid);

        // Render the sines
        for (size_t i = 0; i < num_stars; ++i) {
            apply_star(grid, stars[i]);
        }

        tmr when timerafter(time) :> void;
        pixel_update_strip(neo, grid);
        tmr :> time;

        // Refresh rate limited to 500 frames per second
        time += MILLISECONDS_TICKS/10;

        if ((iter & 0xff) == 0) {
            // Regularly allow a start to move
            do_move = 1;
        }

        if (do_move) {
            // Try to move a star that is dark
            for (size_t attempt = 0; attempt < 5; ++attempt) {
                size_t index = random_get_random_number(rand) % num_stars;
                if (stars[index].brightness < 10) {
                    randomize_star(grid, stars[index], rand);
                    do_move = 0;
                    break;
                }
            }
        }
    }
}

int main() {
    par {
      pattern_task(p, GRID(10, 10));
    }

    return 0;
}

