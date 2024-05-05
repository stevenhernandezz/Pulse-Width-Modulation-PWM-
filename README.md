# Pulse-Width-Modulation-PWM-
 This project uses the Zybo-Z7 development board to implement a Pulse Width Modulation (PWM) to change the intensity of the on board RGB LEDs. 
 
## Description
For this project I made the module for the enhanced PWM architecture as well as a module for the led intensity. I then instantiated the PWM module into my led intensity and chose a resolution of 8 bits for the PWM which is 256 values. From there I made sure the rate for the intensity change was 50 Hz as well as have a system clock of 125 MHz, and PWM frequency of 
100 Hz. I also used an IP for the system clock settings and mapped the LED to only the red color. 

## Demo Video
https://www.youtube.com/watch?v=EzUJAUz-DmA

## Dependencies
## Hardware
* https://digilent.com/reference/programmable-logic/zybo-z7/start

### Software
* https://www.xilinx.com/products/design-tools/vivado.html

### Author
* Steven Hernandez
  - www.linkedin.com/in/steven-hernandez-a55a11300
  - https://github.com/stevenhernandezz
