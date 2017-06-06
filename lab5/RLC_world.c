
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
#define led_out (void *) 0x000810b0
#define switches_in (volatile char *) 0x000810a0
#define inputData (volatile char *) 0x00081090
#define KEY_321_in (void *) 0x00081080
#define outputData (char *) 0x00081070
#define HEX0 (void *) 0x00081060
#define outputClockEn (void *) 0x00081050
#define VGA_reset (void *) 0x00081040
#define VGA_rgb_out (void *) 0x00081030
#define VGA_x_cord (void *) 0x00081020
#define VGA_y_cord (void *) 0x00081010
#define VGA_clock_out (void *) 0x00081000

typedef int bool;
#define true 1
#define false 0

#define player1_mask 0b111110
#define player2_mask 0b11111000000

bool chooseMenu = false;
char lastKey1 = 0;
char lastKey2 = 0;
char lastKey3 = 0;
char lastKeyMenu = 0;

// Game modes
bool player1 = true;
bool inMenu = true;
bool ISoC = false;

// States keeper
short player1_state = 0;
short player2_state = 0;
short VGAout = 0;
char last_input = 0;
char input_state = 0;
char output_state = 0;
char last_state = 0;

// States flags
bool switch_changed = false;
bool state_undated = false;
bool input_changed = false;
bool menu_lock = false;
bool schematic = false;
bool start_dice = false;
bool moving = false;

// dice states
bool stopDice = false;
bool dice_rolling = false;
bool dice_number = 0;

// Counters
unsigned int wait_counter = 0;
unsigned int dice_counter = 0;

void delays (int num);
void menuSelector ();
bool key1 (bool input);
bool key2 (bool input);
bool key3 (bool input);
char outputMenu();
char outputPosition (short position);
void updateOutputData(char output);
void updateMenu ();
void VGAupdate(short position1, short position2);
void Initialise();
short nextState (short position);

int main () {
	Initialise();
	//while () {} // 2 SoCs
	//while () {} // 1 SoC
	/*
	 * while(1) {
	 * delays(50000);
	 * alt_printf("running");
	 * delays(50000);
	 * alt_printf("running");
	 * }
	 */
	/*
	 * while(1) {
	 * char key = 0;
	 * alt_printf("%x\n", key);
	 * }
	 */
	while(1) {
		char test1 = 0;
		char test2 = 0;
		input_state = IORD_ALTERA_AVALON_PIO_DATA(inputData);
		delays(50);
		if (inMenu = !(input_state & 0b1) && !schematic) {
			menuSelector();
			schematic = key1(schematic);

			// A change is made for the menu
			if ((chooseMenu ^ ((last_state & 0b10) >> 1)) != 0) {
                last_state = outputMenu();
				switch_changed = true;
			}

			// The user chose and go to schematic
			if ((schematic ^ (last_state & 0b1)) != 0) {
				last_state = outputMenu();
				VGAupdate(player2_state, player1_state);
				//delays(100000);
			}

			// The state where SoC 2 made a change
			//test2 = (input_state ^ last_input);
			//alt_printf("%x\n", test2);
			if (input_changed = (input_state ^ last_input) != 0 && !switch_changed) {
				chooseMenu = input_state >> 1;
				updateMenu();
				last_state = outputMenu();
				ISoC = !((last_state & 2) >> 1);
			}

			// The state where SoC 1 made a change and SoC 2 received it
			//test1 = (input_state ^ last_state);
			//alt_printf("%x\n", test1);
			if (state_undated = (input_state ^ last_state) == 0 && switch_changed) {
				updateMenu();
				switch_changed = false;
				ISoC = !((last_state & 2) >> 1);
			}

			last_input = input_state;
		}
		/*else {
			if (ISoC) {
				if (!schematic) {
					schematic = key1(schematic);
				} else {
					//alt_printf("running schematic");
					// Rolling dice
					if (dice_counter == 0 && !moving) {
						dice_rolling = key1(dice_rolling);
						alt_printf("%x\n", dice_rolling);
					}
					if (dice_rolling) {
						stopDice = key2(stopDice);
						alt_printf("%x\n", stopDice);
					}
					if (stopDice) {
						dice_counter = 0;
						moving = true;
						dice_rolling = false;
						dice_number = dice_counter % 4 + 1;
					} else
						dice_counter++;


					if (!dice_rolling && moving) {
						if (player1) {
							player1_state = nextState(player1_state);
						} else
							player2_state = nextState(player2_state);

						// If the player is not moving anymore, switch player
						if (!moving)
							player1 = ~player1;
					}

					VGAupdate(player2_state, player1_state);
				}
			} else {
				outputPosition(0);
				VGAupdate(player2_state, player1_state);
			}
		}
		*/
	}
	return 1;
}

void delays (int num) {
	for (int i; i < num; i++){}
}

void menuSelector () {
	char keys = IORD_ALTERA_AVALON_PIO_DATA(KEY_321_in);

	if ((keys & 0b100) >> 2 || (lastKeyMenu & 0b100) >> 2) { // & 3b100
		keys = IORD_ALTERA_AVALON_PIO_DATA(KEY_321_in);
		if(!((keys & 0b100) >> 2)) {
			chooseMenu = ~chooseMenu;
			switch_changed = true;
		}
	}

	lastKeyMenu = keys;
}

bool key1 (bool input) {
	char keys = IORD_ALTERA_AVALON_PIO_DATA(KEY_321_in);
    if ((keys & 0b1) || (lastKey1 & 0b1)) {
      	keys = IORD_ALTERA_AVALON_PIO_DATA(KEY_321_in);
        if (!(keys & 0b1)) {
          	input = ~input;
        }
    }

	lastKey1 = keys;
	return input;
}

bool key2 (bool input) {
    char keys = IORD_ALTERA_AVALON_PIO_DATA(KEY_321_in);
    if ((keys & 0b10) >> 1 || (lastKey2 & 0b10) >> 1) {
        keys = IORD_ALTERA_AVALON_PIO_DATA(KEY_321_in);
        if (!((keys & 0b10) >> 1)) {
        	input = ~input;
        }
    }

    lastKey2 = keys;
	return input;
}

bool key3 (bool input) {
    char keys = IORD_ALTERA_AVALON_PIO_DATA(KEY_321_in);
    if ((keys & 0b100) >> 2 || (lastKey3 & 0b100) >> 2) {
    	keys = IORD_ALTERA_AVALON_PIO_DATA(KEY_321_in);
        if(!((keys & 0b100) >> 2)) {
        	input = ~input;
        }
    }

    lastKey3 = keys;
	return input;
}

char outputMenu() {
	char output = 0;
	if (chooseMenu)
		output = 0b10;
	else
		output = 0b0;
	updateOutputData(output);
	return output;
}

char outputPosition (short position) {
	char output = (position << 1) | 1;
	updateOutputData(output);
	return output;
}

void updateOutputData(char output) {
	IOWR_ALTERA_AVALON_PIO_DATA(outputData, output);
	IOWR_ALTERA_AVALON_PIO_DATA(outputClockEn, 0b1);
	IOWR_ALTERA_AVALON_PIO_DATA(outputClockEn, 0b0);
}

void updateMenu (){
	if (!chooseMenu) {
		IOWR_ALTERA_AVALON_PIO_DATA(VGA_rgb_out, 0b000000000000000000000000);
	} else {
		IOWR_ALTERA_AVALON_PIO_DATA(VGA_rgb_out, 0b000000000000000000000010);
	}
}

void VGAupdate(short position1, short position2){
	short VGAbytes = (position2 << 7) | (position1 << 1) | 1;
	IOWR_ALTERA_AVALON_PIO_DATA(VGA_rgb_out, 0b000000000000000000000000 | VGAbytes);
}

void Initialise() {
	IOWR_ALTERA_AVALON_PIO_DATA(VGA_rgb_out, 0b000000000000000000000000);
	updateOutputData(0x00);
}


short nextState (short position) {
	if (position >= 0 && position < 25 && dice_number > 0) {
		 position = position + 1;
		 dice_number = dice_number - 1;
	} else if (position == 1 && dice_number == 0) {
		position = 16;
		moving = false;
	} else if (position == 5 && dice_number == 0) {
		position = 12;
		moving = false;
	} else if (position == 10 && dice_number == 0) {
		position = 7;
		moving = false;
	} else if (position == 14 && dice_number == 0) {
		position = 3;
		moving = false;
	} else if (position == 15 && dice_number == 0) {
		position = 20;
		moving = false;
	} else if (position == 17 && dice_number == 0) {
		position = 0;
		moving = false;
	} else if (position == 19 && dice_number == 0) {
		position = 16;
		moving = false;
	} else if (position == 22 && dice_number == 0) {
		position = 13;
		moving = false;
	} else if (position == 24 && dice_number == 0) {
		position = 11;
		moving = false;
	} else if (position == 26 && dice_number == 0) {
		position = 27;
	} else if (position == 27 && dice_number == 0) {
		position = 28;
	} else if (position == 28 && dice_number == 0) {
		position = 29;
	} else if (position == 29 && dice_number == 0) {
		position = 30;
	} else if (position == 30 && dice_number == 0) {
		position = 0;
		moving = false;
	} else if (position == 26 && dice_number == 1) {
		position = 31;
		dice_number = dice_number - 1;
	} else if (position == 31 && dice_number == 0) {
		position = 32;
		moving = false;
	} else if (position == 25) {
		if (dice_counter <= 2) {
			position = position + 1;
			dice_number = dice_number - 1;
		}
	}

	return position;
}
