//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// by Peter Hedinger
//
#ifndef __neogrid_h__
#define __neogrid_h__

#include <stdint.h>

#ifdef __XC__
extern "C" {
#endif

#define SPEED_800KHZ 1

#if SPEED_400KHZ
#define T0H_TICKS 50
#define T0L_TICKS 200
#define T1H_TICKS 125
#define T1L_TICKS 125
#elif SPEED_800KHZ
// This is not what the spec of the WS2811 datasheet says, but it seems to work
// while the defined timings of 25/100 & 62/63 don't work at all
#define T0H_TICKS 45
#define T0L_TICKS 80
#define T1H_TICKS 80
#define T1L_TICKS 45
#else
#error "Must define either SPEED_800KHZ or SPEED_400KHZ"
#endif

#define MILLISECONDS_TICKS 100000

#define SCALE_FACTOR_LOG2 8
#define SCALE_FACTOR (1 << (SCALE_FACTOR_LOG2))

void linear_interpolation(size_t val, size_t points_per_pixel_log2,
    size_t *index, size_t *scale1, size_t *scale2);

/*** State for storing pixel data
 *
 * Use integers so that comparisons are correct with positions that can go < 0
 */
typedef struct grid_state_t {
    int num_cols;               /**< Number of columns in the grid. */
    int num_rows;               /**< Number of rows in the grid. */
    int max_x;
    int max_y;
    int points_per_gap_x_log2;
    int points_per_gap_y_log2;
    int brightness;             /**< Brightness of the entire grid. 256 = Max brightness */
    int *colors;                /**< Pixel color values that will be saturated
                                     to [0-255] when displayed */
    uint8_t *saturated_colors;  /**< Memory block into which the saturated pixels
                                     are written. */
} grid_state_t;

inline size_t grid_num_colors(grid_state_t *grid) {
    // Colors are RGB (3-bytes per pixel)
    return 3 * grid->num_cols * grid->num_rows;
}

void grid_init(grid_state_t *grid,
         const size_t num_cols, const size_t points_per_gap_x_log2,
         const size_t num_rows, const size_t points_per_gap_y_log2,
         const int brightness,
         int *colors, uint8_t *saturated_colors);

void grid_reset_colors(grid_state_t *grid);

void pixel_set_pixel_rgb(grid_state_t *grid,
        size_t pixel,
        int r, int g, int b);

void set_col_row_rgb(grid_state_t *grid,
        size_t col, size_t row,
        int r, int g, int b);

void pixel_set_col_row_rgb(grid_state_t *grid,
        size_t col, size_t row,
        int r, int g, int b);

void pixel_set_row_rgb(grid_state_t *grid, size_t row,
        int r, int g, int b);

void pixel_set_col_rgb(grid_state_t *grid, size_t col,
        int r, int g, int b);

void pixel_interpolate_row_rgb(grid_state_t *grid, size_t y,
        int r, int g, int b);

void pixel_interpolate_col_rgb(grid_state_t *grid, size_t x,
        int r, int g, int b);

void pixel_set_rgb(grid_state_t *grid,
        int r, int g, int b);

#ifdef __XC__
} // extern 'C'
#endif

#ifdef __XC__
/*** Render the pixel state to the physical pixels
 */
void pixel_update_strip(out port neo, grid_state_t &grid);
#endif


#endif // __neogrid_h__