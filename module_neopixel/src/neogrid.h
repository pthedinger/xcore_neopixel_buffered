//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// by Peter Hedinger
//
#ifndef __neogrid_h__
#define __neogrid_h__

#include <stddef.h>

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

#ifndef NUM_ROWS
#define NUM_ROWS 5
#endif

#ifndef NUM_COLS
#define NUM_COLS 10
#endif

#define NUM_PIXELS ((NUM_ROWS)*(NUM_COLS))
#define NUM_COLORS (3*(NUM_PIXELS))

/*** State for storing pixel data
 */
typedef struct pixel_state_t {
    int brightness;             /**< Brightness of the entire grid. 256 = Max brightness */
    int values[NUM_COLORS];     /**< Pixel values that will be saturated to [0-255] */
} pixel_state_t;

/*** Render the pixel state to the physical pixels
 */
void pixel_update_strip(out port neo, pixel_state_t &pixels);

void pixel_set_pixel_rgb(pixel_state_t &pixels,
        size_t pixel,
        int r, int g, int b);

void set_row_col_rgb(pixel_state_t &pixels,
        size_t row, size_t col,
        int r, int g, int b);

void pixel_set_row_col_rgb(pixel_state_t &pixels,
        size_t row, size_t col,
        int r, int g, int b);

void pixel_set_row_rgb(pixel_state_t &pixels, size_t row,
        int r, int g, int b);

void pixel_set_col_rgb(pixel_state_t &pixels, size_t col,
        int r, int g, int b);

void pixel_set_rgb(pixel_state_t &pixels,
        int r, int g, int b);

#endif // __neogrid_h__