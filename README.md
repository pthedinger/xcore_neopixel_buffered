##XCore Driver for Adafruit NeoPixel Strips

###Introduction
This project provides a general purpose frame buffered XCore driver **module_neopixel** for controlling [Adafruit NeoPixel](http://www.adafruit.com/category/37_168) strips.

It also includes an example application similar to the Adafruit strandtest but written in xC.  This program is able to control 8 NeoPixel strips from an XMOS startKIT.  The multiple strips are individually timed, displaying LED patterns each at their own speed.

There is another example project using this NeoPixel driver together with an ultrasonic range finder driver for XCore located [here](https://github.com/teachop/xcore_ping).

For additional information on the NeoPixel LED strips see [here](http://learn.adafruit.com/adafruit-neopixel-uberguide/overview).

Development and testing of the driver was done on the low cost [XMOS startKIT](http://www.xmos.com/en/startkit).

**NeoPixel timing comments:** There are different integrated circuits at the heart of various NeoPixel brand LED products.  These include WS2811, WS2812, WS2812B, and maybe more.  Timings are not identical for the different parts.  This driver is optimized for the WS2812B, and has been observed to "work" on the others.  If it is required to adjust  timing, three pulse phase constants can be modified in strip_config.h.

###Operation
To decouple creation of pixel color data from the precise serial output timing needed, strip-sized color data is first loaded by generator tasks (in strandtest) into the driver buffers before then being spooled out by driver tasks (neopixel module).  Eight copies of the generator task output to 8 copies of the strip driver task to control 8 strips.  The 8 task pairs run concurrently without synchronization on the 8 CPU cores.  Which is pretty cool!

Since this application generates complete frame buffers before displaying them on the LED strips it will run out of memory somewhere.  That "somewhere" is well past 10,000 LEDS total (that didn't get physically tested, just compiled).  An xCore project that can generate and display unbuffered (in other words without needing the large RAM frame buffers) NeoPixel data full-speed on-the-fly is [here.](https://github.com/teachop/xcore_neopixel_leds)

###Task Handling
In order to pair the generator/driver tasks up correctly on the 8 cores of the startKIT CPU, the task functions are marked as **combinable**.  [Combinable](https://www.xmos.com/en/published/how-define-and-use-combinable-function?secure=1) is a special XMOS xC attribute that allows multiple tasks to run on a single logical core.  The **par()** statements in **main()** start the tasks, combining them in pairs to execute together on each of the cores.

**Concerning tasks:** There are technically no "tasks" as such in the xC language. They are just functions like in C language. It is convention to name them tasks if their main use case is to be called to run in parallel via a **par()** statement.

**A memory usage observation:**  Splitting the driver task and generator task into their own source files for modularity (module_neopixel directory and app_strandtest directory) does make the overall program image larger.  This could use some research - perhaps combinable tasks are optimized when they are in the same compilation unit in a way not possible when they are linked together?  In this case it doesn't matter the whole project is tiny.

###Task Communication and Driver API
The generator/driver tasks communicate via [interfaces](https://www.xmos.com/en/published/how-communicate-between-tasks-interfaces?secure=1) which define message passing transactions.  It was not required to use tasks to seperate the generation and drawing operations on the same core since they are fundamentally serial operations.  However this approach did provide an interesting and structured way to organize the code.

###Places where NeoPixel-ers could Stub A Toe
The driver interface API was designed to be familiar to users of the [Adafruit NeoPixel Library for Arduino](https://github.com/adafruit/Adafruit_NeoPixel).  Because this driver is written in xC, using the powerful multi-core XMOS XCore features, it is not (and should not be) exactly the same.
- Set the length (per strip NeoPixel count) in strip_config.h there is no constructor.
- There is no function overloading in xC (you can use C++ on xCore but I wanted to go all-xC).  Thus the interface for **setPixelColor()** is the same as the Adafruit function when the color is packed, but when using r,g,b parameters the name becomes **setPixelColorRGB()**.
- The data types are different in some cases to match the natural machine size, I **think** this will not create any issue.
- Setting strip brightness (dimming) on the Adafruit library is semi-destructive as the pixel array is modified in-place.  The speed of the xCore allowed the brightness scaling to be applied on-the-fly and the unmodified array retains all the original color information if brightness is later turned back up.
- The API function **getPixels()** which returns a pointer to the raw color data array was omitted in this driver as not being very xC-like.
