# snake-assembly-mips
Snake Game made in Assembly MIPS as a project from University of Brasilia

### How to Play

1. Clone this repository
2. Execute Mars45_Custom5.jar
3. On Mars, go to Settings -> Exception Handler and use SYSTEMv52.s
4. Go to Tools and open Bitmap Display Simulator and Keyboard and Display MMIO Simulator, the formal to displaying the screen and the latter to simulate the user's input. Settings of the Bitmap Display Simulator are shown in the main.s header.
5. Connect both tools to MIPS, assemble the current file and play it. Now all you need to do is to provide input using WASD to change the direction of the snake.

### How to use bmp2bin.c

In case you intend to use your own images on MARS, using 1-byte per color in the Bitmap display.

Usage Instructions:

- Compile the source-code using (preferrably) "clang -O0 -std=c11 bmp2bin.c -o bmp2bin"
- Save your image on Paint as a 256-color Bitmap file (aka 8-bit). This part is prefered to be done on Windows because I am not sure if different softwares use different headers for a 8-bit bitmap file.
- Execute the program doing ./bmp2bin yourimage.bmp yourimage.bin
- Now only the raw bitmap of your image is stored in the binary file, load it with syscalls and store it on the VGA memory as you want.
