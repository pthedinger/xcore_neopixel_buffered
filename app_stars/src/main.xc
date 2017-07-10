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
    uint8_t r;
    uint8_t g;
    uint8_t b;
} star_state_t;


static void randomize_star(grid_state_t &grid, star_state_t &s, random_generator_t &rand)
{
    if ((random_get_random_number(rand) & 0xf) == 0) {
        // The range of valid values is [0-max_x] inclusive
        s.pos_x = random_get_random_number(rand) % (grid.max_x + 1);
        s.pos_y = random_get_random_number(rand) % (grid.max_y + 1);
    } else {
        // Choose a position on a line
        s.pos_x = (random_get_random_number(rand) % grid.num_cols) * (1 << grid.points_per_gap_x_log2);
        s.pos_y = (random_get_random_number(rand) % grid.num_rows) * (1 << grid.points_per_gap_y_log2);
    }
    // Always start it off
    s.brightness = 0;
    // Choosing a random speed of fading (ensuring they don't get stuck off)
    s.dir_speed = (random_get_random_number(rand) & 0x3) + 1;
    s.refresh_divider = (random_get_random_number(rand) & 0x3) + 5;

    s.r = random_get_random_number(rand);
    s.g = random_get_random_number(rand);
    s.b = random_get_random_number(rand);
}

static void apply_star(grid_state_t &grid, star_state_t &s)
{
    size_t row = 0;
    size_t col = 0;
    size_t scale0_x = 0;
    size_t scale1_x = 0;
    size_t scale0_y = 0;
    size_t scale1_y = 0;
    linear_interpolation(s.pos_x, grid.points_per_gap_x_log2, &col, &scale0_x, &scale1_x);
    linear_interpolation(s.pos_y, grid.points_per_gap_y_log2, &row, &scale0_y, &scale1_y);

    const size_t scale = SCALE_FACTOR_LOG2 * 2;
    const size_t scale_00 = scale0_x * scale0_y;
    const size_t scale_01 = scale0_x * scale1_y;
    const size_t scale_10 = scale1_x * scale0_y;
    const size_t scale_11 = scale1_x * scale1_y;
    const int r = ((int)s.r * s.brightness) >> 8;
    const int g = ((int)s.g * s.brightness) >> 8;
    const int b = ((int)s.b * s.brightness) >> 8;

    pixel_set_col_row_rgb(&grid, col, row,
        (scale_00 * r) >> scale,
        (scale_00 * g) >> scale,
        (scale_00 * b) >> scale);

    if (scale_01) {
        pixel_set_col_row_rgb(&grid, col, row+1,
            (scale_01 * r) >> scale,
            (scale_01 * g) >> scale,
            (scale_01 * b) >> scale);
    }
    if (scale_10) {
        pixel_set_col_row_rgb(&grid, col+1, row,
            (scale_10 * r) >> scale,
            (scale_10 * g) >> scale,
            (scale_10 * b) >> scale);
    }
    if (scale_11) {
        pixel_set_col_row_rgb(&grid, col+1, row+1,
            (scale_11 * r) >> scale,
            (scale_11 * g) >> scale,
            (scale_11 * b) >> scale);
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
        {0, 0, 256, -1, 1, 0, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 0xff, 0xff, 0xff},
        {0, 0, 256, -1, 1, 0, 0xff, 0xff, 0xff},
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

