
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
int gameWaitFlag;
int diceRollFlag;
unsigned int diceRollCounter;
int whichPlayer;
int dice;
int lastSerialIn;
int waitOtherSocMoveFlag;
int waitSocCounter;

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
		if (gameFlag == 1)
			SingleSocGame();
		if (gameFlag > 1)
			DualSocGame(serialIn);
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
	gameWaitFlag = 1;
	diceRollFlag = 0;
	diceRollCounter = 0;
	whichPlayer = 1;
	lastSerialIn = 0;
	dice = 0;
	waitOtherSocMoveFlag = 0;
	waitSocCounter = 0;
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

	if (serialIn == 0b00000010 && !menu1Player){
			buttonPush = 0;
			VerilogOut(player2Select);
			buttonPush = Button2Detect();
			if (buttonPush || serialIn == 0b00000000){ // Change menu
				menu1Player = 1;
				outputSerial(0b00000000);
				VerilogOut(player1Select);
			}

			buttonPush = Button1Detect();
			if (buttonPush){ // Confirm Game
				whichPlayer = 1;
				menuFlag = 0;
				gameFlag = 2;
				outputSerial(0b00000001);
				VerilogOut(0b01);
			}
		}
	else if (menu1Player && serialIn == 0x00){
		buttonPush = 0;
		VerilogOut(player1Select);
		buttonPush = Button2Detect();
		if (buttonPush || serialIn == 0b00000010){ // Change menu
			menu2Player = 1;
			menu1Player = 0;
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
	whichPlayer = 1;
	waitOtherSocMoveFlag = 1;
	outputSerial(0b01);
	VerilogOut(0b01);
	menuFlag = 0;
	gameFlag = 3;
}

void SingleSocGame(){
	if (gameWaitFlag == 1){
		gameWaitFlag = 0;
		int i;
		for (i=0; i < 9200000; i++){}
	}
	int button1;
	int button2;
	int diceRollValue;
	int serialOutEnable;
	serialOutEnable = 0;
	diceRollValue = 0;
	button1 = 0;
	button2 = 0;
	button1 = Button1Detect();
	if (button1 && !diceRollFlag){
		diceRollFlag = 1;
		alt_putstr("Test!\n");
	}
	button2 = Button2Detect();
	if (diceRollFlag){
		diceRollCounter ++;
	}
	if (button2 && diceRollFlag){
		diceRollFlag = 0;
		diceRollValue = (diceRollCounter % 4) + 1;
	}
	if(whichPlayer == 1 && diceRollValue > 0){
		MovePlayer1(diceRollValue, serialOutEnable);
		whichPlayer = 2;
	}
	else if(whichPlayer == 2 && diceRollValue > 0){
		MovePlayer2(diceRollValue, serialOutEnable);
		whichPlayer = 1;
	}
}

void DualSocGame(int serialIn){
	if (gameWaitFlag == 1){
		whichPlayer = 1;
		gameWaitFlag = 0;
		int i;
		for (i=0; i < 9200000; i++){}
	}
	int button1;
	int button2;
	int diceRollValue;
	int serialOutEnable;
	int verilogData;
	int serialData;
	serialOutEnable = 0;
	diceRollValue = 0;
	if (lastSerialIn != serialIn && waitOtherSocMoveFlag == 0){
			waitSocCounter = 0;
			waitOtherSocMoveFlag = 1;
		}

	if (waitOtherSocMoveFlag && gameFlag == 3){
		if (whichPlayer == 1){
			if (lastSerialIn != serialIn){ // Move Player 1 (other SoC)
				verilogData = IORD_ALTERA_AVALON_PIO_DATA(verilogOutPointer);
				verilogData = verilogData & 0b111111111111111110000001;
				serialData = serialIn & 0b01111110;
				verilogData = verilogData | serialData;
				VerilogOut(verilogData);
				Delay(550500);
			}
			waitSocCounter = waitSocCounter + 1;
			if (waitSocCounter == 4){
				whichPlayer = 2;
				waitOtherSocMoveFlag = 0;
			}
		}
	}
	if (waitOtherSocMoveFlag && gameFlag == 2){
		if (whichPlayer == 2){
			if (lastSerialIn != serialIn){ // Move Player 2 (other SoC)
				verilogData = IORD_ALTERA_AVALON_PIO_DATA(verilogOutPointer);
				verilogData = verilogData & 0b111111111110000001111111;
				serialData = (serialIn & 0b01111110) << 6;
				verilogData = verilogData | serialData;
				VerilogOut(verilogData);
				Delay(550500);
			}
			waitSocCounter = waitSocCounter + 1;
			if (waitSocCounter == 4){
				whichPlayer = 1;
				waitOtherSocMoveFlag = 0;
			}
		}
	}
	button1 = 0;
	button2 = 0;
	button1 = Button1Detect();
	button2 = Button2Detect();
	if (button1 && !diceRollFlag){
		diceRollFlag = 1;
		alt_putstr("Test!\n");
	}
	button2 = Button2Detect();
	if (diceRollFlag){
		diceRollCounter ++;
	}
	if (button2 && diceRollFlag){
		diceRollFlag = 0;
		diceRollValue = (diceRollCounter % 4) + 1;
	}
	if (whichPlayer == 1 && !waitOtherSocMoveFlag && gameFlag == 2){ // Move Local 1 player
		MovePlayer1(diceRollValue, 1);
		whichPlayer = 2;
	}
	if (whichPlayer == 2 && !waitOtherSocMoveFlag && gameFlag == 3){ // Move Local 2 player
		MovePlayer2(diceRollValue, 1);
		whichPlayer = 1;
	}
	lastSerialIn = serialIn;
}

void MovePlayer1(int diceRollValue, int serialOutEn){
	int i;
	int currentPos;
	int verilogData;
	int store;
	dice = diceRollValue;
	verilogData = IORD_ALTERA_AVALON_PIO_DATA(verilogOutPointer);
	currentPos = verilogData & 0b000000000000000001111110;
	currentPos = currentPos >> 1;
	while(dice >= 0){
		currentPos = MovePlayer(currentPos);
		if (serialOutEn){
			outputSerial(currentPos * 2 + 1);
		}
		verilogData = verilogData & 0b111111111111111110000001;
		store = currentPos << 1;
		store = store | verilogData;
		alt_printf("%x", currentPos);
		VerilogOut(store);
		Delay(550500); // 1/2 second delay
	}
}

void MovePlayer2(int diceRollValue, int serialOutEn){
	int i;
	int currentPos;
	int verilogData;
	int store;
	dice = diceRollValue;
	verilogData = IORD_ALTERA_AVALON_PIO_DATA(verilogOutPointer);
	currentPos = verilogData & 0b000000000001111110000000;
	currentPos = currentPos >> 7;
	while(dice >= 0){
		currentPos = MovePlayer(currentPos);
		if (serialOutEn){
			outputSerial(currentPos * 2 + 1);
		}
		verilogData = verilogData & 0b111111111110000001111111;
		store = currentPos << 7;
		store = store | verilogData;
		VerilogOut(store);
		if (dice >= 0){
			Delay(550500); // 1/2 second delay
		}
	}
}

int MovePlayer(int beginPos){
	int currentPos;
	int subtract;
	subtract = 1;
	currentPos = beginPos;

		if (currentPos == 0 && dice > 0){
			currentPos = currentPos + 1;
		} else
		if (currentPos == 1 && dice > 0){
			currentPos = currentPos + 1;
		} else
		if(currentPos == 1 && dice == 0){ // inductor/Cap slide
			currentPos = 16;
		} else
		if(currentPos == 2 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 3 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 4 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 5 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 5 && dice == 0){ // inductor/Cap slide
			currentPos = 12;
		} else
		if(currentPos == 6 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 7 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 8 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 9 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
			outputSerial(currentPos * 2 + 1);
		} else
		if(currentPos == 10 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 10 && dice == 0){ // inductor/Cap slide
			currentPos = 7;
		} else
		if(currentPos == 11 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 12 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 13 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 14 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 14 && dice == 0){ // inductor/Cap slide
			currentPos = 3;
		} else
		if(currentPos == 15 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 15 && dice == 0){ // inductor/Cap slide
			currentPos = 20;
		} else
		if(currentPos == 16 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 17 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 17 && dice == 0){ // inductor/Cap slide
			currentPos = 0;
		} else
		if(currentPos == 18 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 19 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 19 && dice == 0){ // inductor/Cap slide
			currentPos = 16;
		} else
		if(currentPos == 20 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 21 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 22 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 22 && dice == 0){ // inductor/Cap slide
			currentPos = 13;
		} else
		if(currentPos == 23 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 24 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 24 && dice == 0){ // inductor/Cap slide
			currentPos = 11;
		} else
		if(currentPos == 25 && dice > 0){ // inductor/Cap slide
			currentPos = currentPos + 1;
		} else
		if(currentPos == 26 && dice > 0){ // inductor/Cap slide
			currentPos = 31;
		} else
		if(currentPos == 26 && dice == 0){ // inductor/Cap slide
			subtract = 0;
			currentPos = 27;
		} else
		if(currentPos == 27 && dice == 0){ // inductor/Cap slide
			subtract = 0;
			currentPos = 28;
		} else
		if(currentPos == 28 && dice == 0){ // inductor/Cap slide
			subtract = 0;
			currentPos = 29;
		} else
		if(currentPos == 29 && dice == 0){ // inductor/Cap slide
			subtract = 0;
			currentPos = 30;
		} else
		if(currentPos == 30 && dice == 0){ // inductor/Cap slide
			subtract = 1;
			currentPos = 0;
		} else
		if(currentPos == 31 && dice == 0){ // inductor/Cap slide
			subtract = 1;
			currentPos = 32;
		}
		if (subtract){
			dice = dice - 1;
		}
		return currentPos;
}

void Delay(int j){
	int i;
	for(i=0; i < j; i++){
	}
}
