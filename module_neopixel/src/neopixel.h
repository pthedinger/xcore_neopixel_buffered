//---------------------------------------------------------
// Buffered NeoPixel driver header
// by teachop
//

#ifndef __NEOPIXEL_H__
#define __NEOPIXEL_H__

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

// strip buffering
#define PIXELS(x) ((x)*3)

// pixel wiring does vary
#define NEO_GRB 0
#define NEO_RGB 1

// neopixel driver interface, Adafruit library-like
interface neopixel_if {
    // update strip from driver internal buffer
    void show(void);

    // write to driver internal buffer with packed RGB 8:8:8 value
    void setPixelColor(uint32_t pixel, uint32_t color);

    // write to driver internal buffer individual 8 bit RGB values
    void setPixelColorRGB(uint32_t pixel, uint8_t r, uint8_t g, uint8_t b);

    // set scaling factor when buffer is displayed, 255 is full
    // this is non-destructive and does not change the buffer contents
    void setBrightness(uint8_t brightness);

    // get the RGB 8:8:8 packed color for the given pixel
    uint32_t getPixelColor(uint32_t pixel);

    // get an estimate of milliamps given buffer * brightness
    uint32_t getEstimate(uint32_t scale);

    // utility function to generate packed value from individual 8 bit RGB
    uint32_t Color(uint8_t r, uint8_t g, uint8_t b);

    // get length of strip in pixels
    uint32_t numPixels(void);
};

[[combinable]] void neopixel_task(out port neo,
        static const uint32_t buf_size,   // in bytes, 3 times the pixel count
        uint32_t order,
        interface neopixel_if server dvr);


#endif // __NEOPIXEL_H__
