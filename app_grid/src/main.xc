//-----------------------------------------------------------
// Driving a line of pixels arranged in a grid
// Copyright 2017 - Peter Hedinger
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include "neogrid.h"

out port p = XS1_PORT_1A;

void pattern_task(uint32_t taskID, interface neopixel_if client strip)
{
    grid_set_rgb(strip, 0, 0, 0);

    for (uint32_t iter = 0; ; ++iter) {
        for (int delay_ms = 10; delay_ms > 0; --delay_ms) {
            grid_sweep_up_rgb(strip, delay_ms * 10, 0xff, 0, 0);
            grid_sweep_down_rgb(strip, delay_ms * 10, 0, 0xff, 0);

            grid_sweep_left_rgb(strip, delay_ms * 5, 0xff, 0, 0);
            grid_sweep_right_rgb(strip, delay_ms * 5, 0, 0xff, 0);

            grid_walk_to_rgb(strip, 25, 0, 0, 0xff);
            grid_walk_back_rgb(strip, 25, 0, 0, 0);
        }
    }
}

int main() {
    interface neopixel_if neopixel_strip[8];

    par {
      neopixel_task(p, PIXELS(50), NEO_RGB, neopixel_strip[0]);
      pattern_task(0, neopixel_strip[0] );
    }

    return 0;
}

