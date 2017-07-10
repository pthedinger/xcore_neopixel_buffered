//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// Copyright 2017 - Peter Hedinger
//

#include <stddef.h>
#include <string.h>
#include "debug_print.h"
#include "neogrid.h"

#define VERBOSE 0

void linear_interpolation(size_t val, size_t points_per_pixel_log2,
    size_t *index, size_t *scale1, size_t *scale2)
{
    *index = val >> points_per_pixel_log2;

    const int points_per_pixel = 1 << points_per_pixel_log2;
    const size_t remainder = val - (*index << points_per_pixel_log2);

    *scale1 = points_per_pixel - remainder;
    *scale2 = remainder;

    if (VERBOSE) {
        debug_printf("%d: %d per-pixels: maps to index %d/%d at scale %d/%d\n",
            val, 1<<points_per_pixel_log2, *index, (*index) + 1, *scale1, *scale2);
    }
}

void grid_init(grid_state_t *grid,
         const size_t num_cols, const size_t points_per_gap_x_log2,
         const size_t num_rows, const size_t points_per_gap_y_log2,
         const int brightness,
         int *colors, uint8_t *saturated_colors)
{
    // Need to be in C to initialise the pointer
    grid->num_cols = num_cols;
    grid->num_rows = num_rows;

    // Round to integer values that divide the space between the pixels evenly
    const size_t num_col_gaps = num_cols - 1;
    const size_t num_row_gaps = num_rows - 1;

    grid->max_x = num_col_gaps * (1 << points_per_gap_x_log2);
    grid->max_y = num_row_gaps * (1 << points_per_gap_y_log2);

    grid->points_per_gap_x_log2 = points_per_gap_x_log2;
    grid->points_per_gap_y_log2 = points_per_gap_y_log2;

    grid->brightness = brightness;
    grid->colors = colors;
    grid->saturated_colors = saturated_colors;
}

void grid_reset_colors(grid_state_t *grid)
{
    // Have to call the C-version of memset because colors is an unsafe pointer
    memset(grid->colors, 0, grid_num_colors(grid) * sizeof(int));
}

void pixel_set_pixel_rgb(grid_state_t *grid,
        size_t pixel,
        int r, int g, int b)
{
    size_t index = 3*pixel;
    grid->colors[index++] += r;
    grid->colors[index++] += g;
    grid->colors[index]   += b;
}

void pixel_set_col_row_rgb(grid_state_t *grid,
        size_t col, size_t row,
        int r, int g, int b)
{
    const int odd_col = col & 0x1;
    if (odd_col) {
        row = (grid->num_rows - 1) - row;
    }
    const size_t pixel = col * grid->num_rows + row;
    pixel_set_pixel_rgb(grid, pixel, r, g, b);
}

void pixel_set_row_rgb(grid_state_t *grid, size_t row,
        int r, int g, int b)
{
    for (size_t col = 0; col < grid->num_cols; ++col) {
        pixel_set_col_row_rgb(grid, col, row, r, g, b);
    }
}

void pixel_set_col_rgb(grid_state_t *grid, size_t col,
        int r, int g, int b)
{
    for (size_t row = 0; row < grid->num_rows; ++row) {
        pixel_set_col_row_rgb(grid, col, row, r, g, b);
    }
}

void pixel_interpolate_row_rgb(grid_state_t *grid, size_t y,
        int r, int g, int b)
{
    size_t row = 0;
    size_t scale1 = 0;
    size_t scale2 = 0;
    linear_interpolation(y, grid->points_per_gap_y_log2, &row, &scale1, &scale2);

    int r1 = (r*scale1) >> SCALE_FACTOR_LOG2;
    int g1 = (g*scale1) >> SCALE_FACTOR_LOG2;
    int b1 = (b*scale1) >> SCALE_FACTOR_LOG2;
    for (size_t col = 0; col < grid->num_cols; ++col) {
        pixel_set_col_row_rgb(grid, col, row, r1, g1, b1);
    }
    if (scale2) {
        int r2 = (r*scale2) >> SCALE_FACTOR_LOG2;
        int g2 = (g*scale2) >> SCALE_FACTOR_LOG2;
        int b2 = (b*scale2) >> SCALE_FACTOR_LOG2;
        for (size_t col = 0; col < grid->num_cols; ++col) {
            pixel_set_col_row_rgb(grid, col, row+1, r2, g2, b2);
        }
    }
}

void pixel_interpolate_col_rgb(grid_state_t *grid, size_t x,
        int r, int g, int b)
{
    size_t col = 0;
    size_t scale1 = 0;
    size_t scale2 = 0;
    linear_interpolation(x, grid->points_per_gap_x_log2, &col, &scale1, &scale2);

    int r1 = (r*scale1) >> SCALE_FACTOR_LOG2;
    int g1 = (g*scale1) >> SCALE_FACTOR_LOG2;
    int b1 = (b*scale1) >> SCALE_FACTOR_LOG2;
    for (size_t row = 0; row < grid->num_rows; ++row) {
        pixel_set_col_row_rgb(grid, col, row, r1, g1, b1);
    }
    if (scale2) {
        int r2 = (r*scale2) >> SCALE_FACTOR_LOG2;
        int g2 = (g*scale2) >> SCALE_FACTOR_LOG2;
        int b2 = (b*scale2) >> SCALE_FACTOR_LOG2;
        for (size_t row = 0; row < grid->num_rows; ++row) {
            pixel_set_col_row_rgb(grid, col+1, row, r2, g2, b2);
        }
    }
}

void pixel_set_rgb(grid_state_t *grid,
        int r, int g, int b)
{
    for (size_t row = 0; row < grid->num_rows; ++row) {
        pixel_set_row_rgb(grid, row, r, g, b);
    }
}

