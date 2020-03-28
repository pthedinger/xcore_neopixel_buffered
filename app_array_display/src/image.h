#ifndef __image_h__
#define __image_h__

#define WHITE     { 255, 255, 255 }
#define RED       { 255,   0,   0 }
#define LGREEN    {   0, 184, 144 }
#define GREEN     {   0, 255,   0 }
#define BLUE      {   0,   0, 255 }
#define LBLUE     { 100, 100, 255 }
#define YELLOW    { 255, 255,   0 }
#define ORANGE    { 237, 122,  14 }
#define BROWN     {  20,  20,  20 }
#define PINK      { 230,  20, 220 }
#define PURPLE    { 120,   0, 120 }
#define BLACK     {   0,   0,   0 }
#define BEIGE     { 164, 120,  80 }
#define BLA       {   42, 42,  42 }

typedef struct {
    uint8_t r;
    uint8_t g;
    uint8_t b;
} pixel_t;

typedef pixel_t image_t[NUM_ROWS * NUM_COLS];
#define NUM_IMAGES  2
image_t images[NUM_IMAGES] = {
     // { /* Easter egg */
     //     BLACK,  BLACK,  BLACK,  BLACK,    RED,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
     //     BLACK,  BLACK,  BLACK,    RED,    RED,    RED,  BLACK,  BLACK,  BLACK,  BLACK, 
     //     BLACK,  BLACK,  BLACK,    RED,    RED,    RED,  BLACK,  BLACK,  BLACK,  BLACK, 
     //     BLACK,  BLACK,    RED,    RED, PURPLE, ORANGE,    RED,  BLACK,  BLACK,  BLACK, 
     //     BLACK,    RED,    RED,    RED,    RED,    RED,    RED,    RED,  BLACK,  BLACK, 
     //     BLACK,    RED,    RED,    RED,  GREEN, YELLOW,    RED,    RED,  BLACK,  BLACK, 
     //     BLACK,    RED,    RED,    RED,    RED,  LBLUE,    RED,    RED,  BLACK,  BLACK, 
     //     BLACK,    RED,    RED,    RED,    RED,    RED,    RED,    RED,  BLACK,  BLACK, 
     //     BLACK,  BLACK,    RED,    RED,  LBLUE,    RED,    RED,  BLACK,  BLACK,  BLACK, 
     //     BLACK,  BLACK,  BLACK,    RED,    RED,    RED,  BLACK,  BLACK,  BLACK,  BLACK, 
     // },

     // { /* Pokeball */
     //     BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
     //     BLACK,  BLACK,  BLACK,    RED,    RED,    RED,    RED,  BLACK,  BLACK,  BLACK, 
     //     BLACK,  BLACK,    RED,    RED,    RED,    RED,    RED,    RED,  BLACK,  BLACK, 
     //     BLACK,    RED,    RED,    RED,    RED,    RED,    RED,    RED,    RED,  BLACK, 
     //       RED,    RED,    RED,    RED,  BLACK,  BLACK,    RED,    RED,    RED,    RED, 
     //     WHITE,  WHITE,  WHITE,  WHITE,  BLACK,  BLACK,  WHITE,  WHITE,  WHITE,  WHITE, 
     //     BLACK,  WHITE,  WHITE,  WHITE,  WHITE,  WHITE,  WHITE,  WHITE,  WHITE,  BLACK, 
     //     BLACK,  BLACK,  WHITE,  WHITE,  WHITE,  WHITE,  WHITE,  WHITE,  BLACK,  BLACK, 
     //     BLACK,  BLACK,  BLACK,  WHITE,  WHITE,  WHITE,  WHITE,  BLACK,  BLACK,  BLACK, 
     //     BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
     // },

     // { /* Multi */
     //     LBLUE,    RED,  GREEN,   BLUE, YELLOW, ORANGE, PURPLE,   PINK,  WHITE, LGREEN, 
     //       RED,  GREEN,   BLUE, YELLOW, ORANGE, PURPLE,   PINK,  WHITE, LGREEN,  LBLUE,
     //     GREEN,   BLUE, YELLOW, ORANGE, PURPLE,   PINK,  WHITE, LGREEN,  LBLUE,    RED,
     //      BLUE, YELLOW, ORANGE, PURPLE,   PINK,  WHITE, LGREEN,  LBLUE,    RED,  GREEN, 
     //    YELLOW, ORANGE, PURPLE,   PINK,  WHITE, LGREEN,  LBLUE,    RED,  GREEN,   BLUE, 
     //    ORANGE, PURPLE,   PINK,  WHITE, LGREEN,  LBLUE,    RED,  GREEN,   BLUE, YELLOW,
     //    PURPLE,   PINK,  WHITE, LGREEN,  LBLUE,    RED,  GREEN,   BLUE, YELLOW, ORANGE, 
     //      PINK,  WHITE, LGREEN,  LBLUE,    RED,  GREEN,   BLUE, YELLOW, ORANGE, PURPLE,
     //     WHITE, LGREEN,  LBLUE,    RED,  GREEN,   BLUE, YELLOW, ORANGE, PURPLE,   PINK,
     //    LGREEN,  LBLUE,    RED,  GREEN,   BLUE, YELLOW, ORANGE, PURPLE,   PINK,  WHITE, 
     // },

     // { /* Multi */
     //     LBLUE,    RED,  GREEN,   BLUE, YELLOW, ORANGE, PURPLE,   PINK,  WHITE, LGREEN, 
     //       RED,  GREEN,   BLUE, YELLOW, ORANGE, PURPLE,   PINK,  WHITE, LGREEN,  LBLUE,
     //     GREEN,   BLUE, YELLOW, ORANGE, PURPLE,   PINK,  WHITE, LGREEN,  LBLUE,    RED,
     //      BLUE, YELLOW, ORANGE, PURPLE,   PINK,  WHITE, LGREEN,  LBLUE,    RED,  GREEN, 
     //    YELLOW, ORANGE, PURPLE,   PINK,  WHITE, LGREEN,  LBLUE,    RED,  GREEN,   BLUE, 
     //    ORANGE, PURPLE,   PINK,  WHITE, LGREEN,  LBLUE,    RED,  GREEN,   BLUE, YELLOW,
     //    PURPLE,   PINK,  WHITE, LGREEN,  LBLUE,    RED,  GREEN,   BLUE, YELLOW, ORANGE, 
     //      PINK,  WHITE, LGREEN,  LBLUE,    RED,  GREEN,   BLUE, YELLOW, ORANGE, PURPLE,
     //     WHITE, LGREEN,  LBLUE,    RED,  GREEN,   BLUE, YELLOW, ORANGE, PURPLE,   PINK,
     //    LGREEN,  LBLUE,    RED,  GREEN,   BLUE, YELLOW, ORANGE, PURPLE,   PINK,  WHITE, 
     // },

    { /* Rainbow */
         BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,    RED, ORANGE, YELLOW,  GREEN, 
         BLACK,  BLACK,  BLACK,  BLACK,  BLACK,    RED, ORANGE, YELLOW,  GREEN,  LBLUE, 
         BLACK,  BLACK,  BLACK,  BLACK,    RED, ORANGE, YELLOW,  GREEN,  LBLUE,   BLUE, 
         BLACK,  BLACK,  BLACK,    RED, ORANGE, YELLOW,  GREEN,  LBLUE,   BLUE, PURPLE, 
         BLACK,  BLACK,    RED, ORANGE, YELLOW,  GREEN,  LBLUE,   BLUE, PURPLE,  BLACK, 
         BLACK,    RED, ORANGE, YELLOW,  GREEN,  LBLUE,   BLUE, PURPLE,  BLACK,  BLACK, 
         BLACK,    RED, YELLOW,  GREEN,  LBLUE,   BLUE, PURPLE,  BLACK,  BLACK,  BLACK, 
         BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
         BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW,  BROWN,  BLACK,  BLACK, 
         BLACK,  BROWN,  BROWN,  BROWN,  BROWN,  BROWN,  BROWN,  BLACK,  BLACK,  BLACK, 
    },

    { /* Rainbow */
         BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,    RED, ORANGE, YELLOW,  GREEN, 
         BLACK,  BLACK,  BLACK,  BLACK,  BLACK,    RED, ORANGE, YELLOW,  GREEN,  LBLUE, 
         BLACK,  BLACK,  BLACK,  BLACK,    RED, ORANGE, YELLOW,  GREEN,  LBLUE,   BLUE, 
         BLACK,  BLACK,  BLACK,    RED, ORANGE, YELLOW,  GREEN,  LBLUE,   BLUE, PURPLE, 
         BLACK,  BLACK,    RED, ORANGE, YELLOW,  GREEN,  LBLUE,   BLUE, PURPLE,  BLACK, 
         BLACK,    RED, ORANGE, YELLOW,  GREEN,  LBLUE,   BLUE, PURPLE,  BLACK,  BLACK, 
         BLACK,    RED, YELLOW,  GREEN,  LBLUE,   BLUE, PURPLE,  BLACK,  BLACK,  BLACK, 
         BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
         BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW,  BROWN,  BLACK,  BLACK, 
         BLACK,  BROWN,  BROWN,  BROWN,  BROWN,  BROWN,  BROWN,  BLACK,  BLACK,  BLACK, 
     },

     // { /* Ladybird */
     //     WHITE,  WHITE,  WHITE,  WHITE,  WHITE,  WHITE,  WHITE,  WHITE,  WHITE,  WHITE, 
     //     WHITE,  WHITE,  WHITE, PURPLE,  WHITE,  WHITE, PURPLE,  WHITE,  WHITE,  WHITE, 
     //     WHITE,  WHITE,  WHITE,  WHITE, PURPLE, PURPLE,  WHITE,  WHITE,  WHITE,  WHITE, 
     //     WHITE,  WHITE,  WHITE,    RED,    RED,    RED,    RED,  WHITE,  WHITE,  WHITE, 
     //     WHITE,  WHITE,    RED, PURPLE,    RED,    RED, PURPLE,    RED,  WHITE,  WHITE, 
     //     WHITE,    RED,    RED,    RED,    RED,    RED,    RED,    RED,    RED,  WHITE, 
     //     WHITE,    RED,    RED,    RED, PURPLE,    RED,    RED,    RED,    RED,  WHITE, 
     //     WHITE,    RED,    RED,    RED,    RED,    RED, PURPLE,    RED,    RED,  WHITE, 
     //     WHITE,  WHITE,    RED, PURPLE,    RED,    RED,    RED,    RED,  WHITE,  WHITE, 
     //     WHITE,  WHITE,  WHITE,    RED,    RED,    RED,    RED,  WHITE,  WHITE,  WHITE, 
     // },

    //  {
    //      BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
    //      BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
    //      BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
    //      BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
    //      BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
    //      BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
    //      BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
    //      BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
    //      BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
    //      BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK,  BLACK, 
    //  },
};

static void render_image(grid_state_t &grid, image_t &image)
{
    for (size_t col = 0; col < grid.num_cols; ++col) {
        for (size_t row = 0; row < grid.num_rows; ++row) {
            pixel_t &pixel = image[col + row*grid.num_cols];
            pixel_set_col_row_rgb(&grid, col, row, pixel.r, pixel.g, pixel.b);
        }
    }
}

static void transition_image(out port neo, grid_state_t &grid, image_t &from, image_t &to, int &time)
{
    timer tmr;
    for (size_t offset = 1; offset <= grid.num_cols; ++offset) {
        grid_reset_colors(&grid);

        for (size_t col = offset; col < (grid.num_cols + offset); ++col) {
            for (size_t row = 0; row < grid.num_rows; ++row) {
                if (col >= grid.num_cols) {
                    pixel_t &pixel = to[(col - grid.num_cols) + row*grid.num_cols];
                    pixel_set_col_row_rgb(&grid, (col - offset), row, pixel.r, pixel.g, pixel.b);
                } else {
                    pixel_t &pixel = from[col + row*grid.num_cols];
                    pixel_set_col_row_rgb(&grid, (col - offset), row, pixel.r, pixel.g, pixel.b);
                }
            }
        }

        tmr when timerafter(time) :> void;
        pixel_update_strip(neo, grid);
        tmr :> time;
        time += 100 * MILLISECONDS_TICKS;
    }
}

#endif // __image_h__
