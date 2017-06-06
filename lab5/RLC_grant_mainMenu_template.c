
/*
	  int c;
	  alt_putstr("Enter 1 to emulate 2 player input Serial!\n");
	  c = getchar();
	  getchar(); // Consume newline
	  if ( c == '1'){
		  IOWR_ALTERA_AVALON_PIO_DATA(outputData, 0b00000001); //store character in outputData register
		  IOWR_ALTERA_AVALON_PIO_DATA(outputClockEn, 0b1); //begin data transfer
		  IOWR_ALTERA_AVALON_PIO_DATA(outputClockEn, 0b0); //begin data transfer
	  }
	  alt_putstr("Current gameFlag Value:\n");
	  alt_printf("%x\n", gameFlag);
*/ 
/*
  *
  *
  *	IOWR_ALTERA_AVALON_PIO_DATA(targetAddress, aValue);
  *	aValue = IORD_ALTERA_AVALON_PIO_DATA(sourceAddress);
  *		used to write or read from a memory address.
  *
  *           Function                  Description
  *        ===============  =====================================
  *        alt_printf       Only supports %s, %x, and %c ( < 1 Kbyte)
  *        alt_putstr       Smaller overhead than puts with direct drivers
  *                         Note this function doesn't add a newline.
  *        alt_putchar      Smaller overhead than putchar with direct drivers
  *        alt_getchar      Smaller overhead than getchar with direct drivers
  *
  */

#include "sys/alt_stdio.h"
#include <stdio.h>
#include "altera_avalon_pio_regs.h"
#define states (void *) 0x000810b0
#define switches_in (volatile char *) 0x000810a0
#define inputData (volatile char *) 0x00081090
#define KEY_321_in (void *) 0x00081080 // 3 bit input
#define outputData (char *) 0x00081070
#define HEX0 (void *) 0x00081060
#define outputClockEn (void *) 0x00081050
#define VGA_reset (void *) 0x00081040
#define verilogOutPointer (void *) 0x00081030
#define VGA_x_cord (void *) 0x00081020
#define VGA_y_cord (void *) 0x00081010
#define VGA_clock_out (void *) 0x00081000

int menuFlag;
int gameFlag;
int player1Select;
int player2Select;
int menu1Player;
int menu2Player;
int lastButton1;
int lastButton2;

int main()
{
	InitializeGlobal();
	outputSerial(0x00);

	while(1){ // Enter Main loop
		char serialIn;
		serialIn = IORD_ALTERA_AVALON_PIO_DATA(inputData);
		
		if (menuFlag){ // menuLoop
			if (serialIn == 0b00000001){
				if(menu2Player){
					definePlayer2();
				}
			}
			else {
				MainMenu(serialIn);
			}
		}
		if(gameFlag > 0){ // BoardGame Loop
			
		}

	}
}

void InitializeGlobal(){ // Initialize global variables and states
	IOWR_ALTERA_AVALON_PIO_DATA(outputClockEn, 0b0);
	menuFlag = 1;
	gameFlag = 0;
	player1Select = 0b00;
	player2Select = 0b10;
	menu1Player = 1;
	menu2Player = 0;
	lastButton1 = 0;
	lastButton2 = 0;
}

void outputSerial(char data){ // Send out Data
	IOWR_ALTERA_AVALON_PIO_DATA(outputData, data);
	IOWR_ALTERA_AVALON_PIO_DATA(outputClockEn, 0b1);
	IOWR_ALTERA_AVALON_PIO_DATA(outputClockEn, 0b0);
}

void VerilogOut(int output){
	IOWR_ALTERA_AVALON_PIO_DATA(verilogOutPointer, output);
}

void MainMenu(char serialIn){
	int buttonPush;

	if (menu1Player && serialIn == 0x00){
		buttonPush = 0;
		menu2Player = 0;
		VerilogOut(player1Select);
		buttonPush = Button2Detect();
		if (buttonPush || serialIn == 0b00000010){ // Change menu
			menu2Player = 1;
			outputSerial(0b00000010);
			VerilogOut(player2Select);
		}

		buttonPush = Button1Detect();
		if (buttonPush){ // Confirm Game
			menuFlag = 0;
			gameFlag = 1;
			outputSerial(0b00000001);
			VerilogOut(0b01);
		}
	}
	if (serialIn == 0b00000010){
		buttonPush = 0;
		menu2Player = 1;
		VerilogOut(player2Select);
		buttonPush = Button2Detect();
		if (buttonPush || serialIn == 0b00000000){ // Change menu
			menu1Player = 1;
			outputSerial(0b00000000);
			VerilogOut(player1Select);
		}

		buttonPush = Button1Detect();
		if (buttonPush){ // Confirm Game
			menuFlag = 0;
			gameFlag = 2;
			outputSerial(0b00000001);
			VerilogOut(0b01);
		}
	}
}

int Button1Detect(){
	int button;
	int buttonOut;
	buttonOut = 0;
	button = IORD_ALTERA_AVALON_PIO_DATA(KEY_321_in);
	button = button & 0b100;
	if (button || lastButton1){
		button = IORD_ALTERA_AVALON_PIO_DATA(KEY_321_in);
		button = button & 0b100;
		if (!button){
			buttonOut = 1;
		}
	}
	lastButton1 = button;
	return buttonOut;
}

int Button2Detect(){
	int button;
	int buttonOut;
	buttonOut = 0;
	button = IORD_ALTERA_AVALON_PIO_DATA(KEY_321_in);
	button = button & 0b010;
	if (button || lastButton2){
		button = IORD_ALTERA_AVALON_PIO_DATA(KEY_321_in);
		button = button & 0b010;
		if (!button){
			buttonOut = 1;
		}
	}
	lastButton2 = button;
	return buttonOut;
}

void definePlayer2(){
	outputSerial(0b01);
	VerilogOut(0b01);
	menuFlag = 0;
	gameFlag = 3;
}


