##AVR LogicSum Display
This project demonstrates a simple digital adder implemented on an ATmega328P microcontroller using AVR Assembly. It reads the status of multiple digital switches (logic high inputs), calculates their sum, and displays the result on a 2-digit 7-segment display. The input changes are handled efficiently via external interrupt (INT0).

##Features
Logic Input Summation: Counts the number of active (logic high) digital inputs from a DIP switch or similar source.
2-Digit 7-Segment Display: Shows the calculated sum, ranging from 0 to 99.
Interrupt-Driven Input: Utilizes External Interrupt 0 (INT0) for responsive detection of input changes, ensuring the display updates promptly without continuous polling.
ATmega328P Microcontroller: Designed for common AVR boards like the Arduino Uno (when programmed directly via ISP).
Pure Assembly Language: Written entirely in AVR Assembly, offering a deep understanding of low-level hardware interaction and optimized performance.
How it Works
Input Reading: The microcontroller continuously monitors PORTC to determine which digital inputs (switches) are set to a logic high state.
Sum Calculation: The program counts these high inputs and accumulates their total into a variable.
Display Logic: The accumulated total is then split into tens and units digits.
7-Segment Output: These digits are mapped to the appropriate segments of a 7-segment display and outputted via PORTD and PORTB (to control individual digits and segments).
Interrupt Handling: An external interrupt on INT0 (PD2) is configured to detect any change in the input switches. When a change occurs, the system resets the summation process and re-reads the inputs, ensuring the display is always up-to-date.
Debouncing (Software): While not explicitly a dedicated debouncing routine, the interrupt-driven approach with a slight delay in the main loop helps mitigate some bounce effects by not reacting to every transient signal immediately.

##Hardware Requirements
ATmega328P Microcontroller (or compatible AVR)
2-digit Common Cathode 7-Segment Display
Current Limiting Resistors for the 7-segment display segments
DIP Switch (or individual push buttons/switches) connected to PORTC pins
Pull-down resistors for the input switches on PORTC (if not using internal pull-ups or if switches are open-collector)
Crystal Oscillator (e.g., 16MHz) and capacitors for the microcontroller clock
Power Supply (e.g., 5V)
AVR ISP Programmer (e.g., USBasp) for flashing the .hex file
Pinout Configuration (Example)
PORTC: Digital Inputs from switches (PC0-PC5)
PORTD & PORTB: 7-segment display segments and digit selection
Specific pin mappings for 7-segment need to be checked in the OUTPUT_SEP routine based on your wiring.
PD2 (INT0): Connected to an input switch (e.g., a reset button or the main input change detection line) to trigger the interrupt.
Assembly and Flashing
Assemble the code:

#Bash

avr-gcc -mmcu=atmega328p -DF_CPU=16000000UL -x assembler-with-cpp -c your_project_name.asm -o your_project_name.o
avr-objcopy -O ihex your_project_name.o your_project_name.hex
(Replace your_project_name.asm with the actual filename of your assembly code.)

Flash the .hex file to your ATmega328P:

Bash

avrdude -c usbasp -p m328p -U flash:w:your_project_name.hex:i
(Adjust -c usbasp if you are using a different programmer.)

Contribution
Feel free to fork this repository, make improvements, and submit pull requests.

