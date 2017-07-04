//---------------------------------------------------------
// Buffered NeoPixel driver
// by teachop
//

#include <xs1.h>
#include <stdint.h>
#include "neopixel.h"

#define MICROSECOND_TICKS 100

// The reset code timing is 50us for the WS2811.
#define RESET_TICKS (MICROSECOND_TICKS * 50)

static inline void drive_0(out port neo, int &port_time)
{
    neo @ port_time <: 1;
    port_time += T0H_TICKS;
    neo @ port_time <: 0;
    port_time += T0L_TICKS;
}

static inline void drive_1(out port neo, int &port_time)
{
    neo @ port_time <: 1;
    port_time += T1H_TICKS;
    neo @ port_time <: 0;
    port_time += T1L_TICKS;
}

// ---------------------------------------------------------
// neopixel_task - output driver for one neopixel strip
//
[[combinable]]
void neopixel_task(out port neo, static const uint32_t buf_size,
                   uint32_t order, interface neopixel_if server dvr) {
    const uint32_t length = buf_size/3;
    uint8_t colors[buf_size];
    uint8_t brightness = 0;
    for (uint32_t loop = 0; loop < buf_size; ++loop) {
        colors[loop] = 0;
    }

    neo <: 0;
    delay_ticks(buf_size * 8 * (T1H_TICKS + T1L_TICKS) + 50000);

    while (1) {
        select {

        case dvr.Color(uint8_t r, uint8_t g, uint8_t b) -> uint32_t return_val:
            return_val = ((uint32_t)r << 16) | ((uint32_t)g <<  8) | b;
            break;

        case dvr.numPixels() -> uint32_t return_val:
            return_val = length;
            break;

        case dvr.setBrightness(uint8_t new_brightness):
            brightness = new_brightness + 1;
            break;

        case dvr.getEstimate(uint32_t scale) -> uint32_t return_val:
            for (uint32_t index = return_val = 0; index < buf_size; ++index ) {
                // add all the pwm values assuming linear relationship
                return_val += colors[index];
            }
            if (brightness) {
                // scale down by brightness setting if used
                return_val = (brightness*return_val)>>8;
            }
            // scale to mA, assuming 17 max per
            uint32_t div = (0==scale)? 52 : scale;
            return_val = (4*return_val)/div;
            break;

        case dvr.getPixelColor(uint32_t pixel) -> uint32_t return_val:
            if (pixel < length) {
                uint32_t index = 3*pixel;
                return_val  = (uint32_t)colors[index++] << (order?16:8);//r:g
                return_val |= (uint32_t)colors[index++] << (order?8:16);//g:r
                return_val |= colors[index];
            } else {
                return_val = 0;
            }
            break;

        case dvr.setPixelColor(uint32_t pixel, uint32_t color):
            if (pixel < length) {
                uint32_t index = 3*pixel;
                colors[index++] = color>>(order?16:8);//r:g
                colors[index++] = color>>(order?8:16);//g:r
                colors[index]   = color;//b
            }
            break;

        case dvr.setPixelColorRGB(uint32_t pixel, uint8_t r, uint8_t g, uint8_t b):
            if (pixel < length) {
                uint32_t index = 3*pixel;
                colors[index++] = (order?r:g);
                colors[index++] = (order?g:r);
                colors[index]   = b;
            }
            break;

        case dvr.show():
            // Sync port timer
            int port_time;
            neo <: 0 @ port_time;

            // Allow ticks to get from here to the first port drive
            static const int loop_start_ticks = 125;
            port_time += loop_start_ticks;

            #pragma unsafe arrays
            for (uint32_t index = 0; index < buf_size; ++index) {
                uint32_t color = colors[index];
                if (brightness) {
                    color = (brightness*color)>>8;
                }

                uint32_t bit_count = 8;
                while (bit_count--) {
                    uint32_t bit = (color & 0x80) ? 1 : 0;
                    if (bit) {
                        drive_1(neo, port_time);
                    } else {
                        drive_0(neo, port_time);
                    }
                    color <<= 1;
                }
            }
            // Hold last pixel
            neo @ port_time <: 0;
            break;
        }
    }
}
