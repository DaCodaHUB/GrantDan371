module DE1_SoC (CLOCK_50, KEY, LEDR, SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, GPIO_0, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	input logic CLOCK_50;
	input logic [3:0]KEY;
	input logic [9:0]SW;
	inout logic [17:14]GPIO_0;
	output logic [9:0]LEDR;
	output logic [6:0]HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;
	output logic [7:0]VGA_R, VGA_G, VGA_B; 
   output logic VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS;
	
	//reset declatation
	logic reset;
	assign reset = ~KEY[0];
	
	// Clock divider
	parameter whichClock = 1;
	logic [31:0]clk;
	clock_divider cdiv1 (CLOCK_50, clk);
	
	// Clock Variable declarations and assignments
	logic outputClock, outputData, inputClock, inputData, outputClockEnable;
	assign GPIO_0[14] = outputClock;
	assign GPIO_0[15] = outputData;
	assign inputClock = GPIO_0[16];
	assign inputData = GPIO_0[17];
	
	// Data Storage variable declarations
	logic [7:0] dataInArray, dataOutArray;
	
	// VGA logic declarations
	logic VGA_RLC_reset;
	logic [23:0] VGA_RLC_out;
	logic [7:0] r, g, b;
	logic [23:0] rgb;
	int x;
	int y;
	logic VGA_clock;
	assign r = rgb[23:16];
	assign g = rgb[15:8];
	assign b = rgb[7:0];
	
	// CPU module connection
	RLC_game_system cpuModule(
		.clk_clk(CLOCK_50),                                       //                                    clk.clk
		.led_pio_external_connection_export(LEDR[7:0]),            //            led_pio_external_connection.export
		.reset_reset_n(KEY[0]),                                 //                                  reset.reset_n
		.switches_pio_external_connection_export(SW[7:0]),       //       switches_pio_external_connection.export
		.datain_pio_external_connection_export(dataInArray),         //         datain_pio_external_connection.export
		.keyin_pio_external_connection_export(KEY[3:1]),          //          keyin_pio_external_connection.export
		.dataout_pio_external_connection_export(dataOutArray),        //        dataout_pio_external_connection.export
		.seven_seg_pio_external_connection_export(HEX0),       //      seven_seg_pio_external_connection.export
		.outputclockenable_pio_external_connection_export(outputClockEnable),  // outputclockenable_pio_external_connection.export
		.vgareset_external_connection_export(VGA_RLC_reset),              //              vgareset_external_connection.export
		.vgaout_external_connection_export(VGA_RLC_out),                //                vgaout_external_connection.export
		.vga_x_cord_external_connection_export(x),            //            vga_x_cord_external_connection.export
		.vga_y_cord_external_connection_export(y),         //            vga_y_cord_external_connection.export
		.vga_clock_out_external_connection_export(VGA_clock)          //         vga_clock_out_external_connection.export
	);
	
	
	// VGA module connection
	video_driver
	#(.WIDTH(640), .HEIGHT(480))
	VGA (
		.CLOCK_50, 
		.reset(VGA_RLC_reset), 
		.x(x), 
		.y(y), 
		.r, 
		.g, 
		.b, 
		.VGA_R, 
		.VGA_G, 
		.VGA_B, 
		.VGA_BLANK_N, 
		.VGA_CLK, 
		.VGA_HS, 
		.VGA_SYNC_N, 
		.VGA_VS
	); 
	
	// Logical States and counters
	logic dataTransferEnable, dataStoreEnable, schematicStart, menuStart;
	logic sweepEn;
	shortint unsigned dataTransferCounter;
	shortint unsigned dataInCounter, dataInCounter2, dataInState;
	longint unsigned VGA_timer;
	int slide_timer;
	int R1_1_d;
	int R2_count;
	int R3_count;
	shortint unsigned L1_1;
	shortint unsigned L2_count;
	shortint unsigned L3_count;
	shortint unsigned L4_count;
	shortint unsigned L2_x;
	shortint unsigned L2_y;
	shortint unsigned L3_x;
	shortint unsigned L3_y;
	shortint unsigned L4_x;
	shortint unsigned L4_y;
	shortint unsigned C2_x;
	shortint unsigned C2_y;
	shortint unsigned C3_x;
	shortint unsigned C3_y;
	shortint unsigned C4_x;
	shortint unsigned C4_y;
	shortint unsigned C5_x;
	shortint unsigned C5_y;
	shortint unsigned C6_x;
	shortint unsigned C6_y;
	shortint unsigned C7_x;
	shortint unsigned C7_y;
	shortint unsigned C8_x;
	shortint unsigned C8_y;
	int last_e1_x, last_e1_y, last_e2_x, last_e2_y;
	int check_e1_x, check_e1_y, check_e2_x, check_e2_y;
	int R2_x;
	int R2_y;	
	int R3_x;
	int R3_y;
	int e1_x;
	int e1_y;
	int e2_x;
	int e2_y;
	shortint unsigned GND;
	byte beginTransferByte;
	byte beginTransferByteCheck;
	int R1_current_y;
	shortint unsigned L1_current_y;
	shortint unsigned L2_current_y;
	shortint unsigned L3_current_y;
	shortint unsigned L4_current_y;
	int R2_current_y;
	shortint unsigned R3_current_y;
	shortint unsigned GND_current_y;
	assign beginTransferByte = 8'b11110000;
		
	//e1 demux
	
	mux5bit_e1 e1_pos (.in(VGA_RLC_out[6:1]), .x_out(e1_x), .y_out(e1_y));
	mux5bit_e2 e2_pos (.in(VGA_RLC_out[12:7]), .x_out(e2_x), .y_out(e2_y));
	
	//initialize variables
	initial begin
		menuStart = 0;
		L1_1 = 0;
		schematicStart = 0;
		GND = 0;
		VGA_timer = 0;
		dataInState = 0;
		dataInArray = 8'b0;
		dataInCounter = 0;
		dataInCounter2 = 0;
		dataStoreEnable = 0;
		beginTransferByteCheck= 8'b0;
		rgb = 24'h000000;
		R1_current_y = 0;
		R1_1_d = 0;
		L2_count = 0;
		L2_x = 260;
		L2_y = 243;
		L2_current_y = 0;
		L3_x = 500;
		L3_y = 243;
		L3_current_y = 0;	
		L4_x = 440;
		L4_y = 103;
		L4_current_y = 0;	
		R2_x = 90;
		R2_y = 243;
		R2_current_y = 0;	
		R3_x = 570;
		R3_y = 100;
		R3_current_y = 0;	
		C2_x = 150;
		C2_y = 243;
		C3_x = 390;
		C3_y = 243;
		C4_x = 570;
		C4_y = 243;
		C5_x = 210;
		C5_y = 103;
		C6_x = 330;
		C6_y = 103;
		C7_x = 510;
		C7_y = 103;
		C8_x = 30;
		C8_y = 243;
		slide_timer = 1;
		sweepEn = 0;
	end
	
	
	
	always_ff @(posedge CLOCK_50) //VGA control FF //COLORS RED: cc5a71 WHITE: f2efea BLUE: 44ccff BLACK: 03191e GREEN 91cb3e GREY: 525252 BROWN: 632d00
		begin										//Dark Grey: 1e1c1b // Dark Green: 0e6500
			if(VGA_RLC_out[0] == 1)
				begin
						menuStart <= 0;
						rgb[23:16] <= 8'h03 /4;
						rgb[15:8] <= 8'h19 /4;
						rgb[7:0] <= 8'h1e /4;
						if (((check_e1_x != e1_x) || (check_e1_y != e1_y) || (check_e2_x != e2_x) || (check_e2_y != e2_y)) && !sweepEn)
							begin
								sweepEn <= 1;
								slide_timer <= 120;
								last_e1_x <= check_e1_x;
								last_e1_y <= check_e1_y;
								last_e2_x <= check_e2_x;
								last_e2_y <= check_e2_y;
							end
						else
							begin
								check_e1_x <= e1_x;
								check_e1_y <= e1_y;
								check_e2_x <= e2_x;
								check_e2_y <= e2_y;
							end
						if (slide_timer == 0 && sweepEn)
								begin
									sweepEn <= 0;
								end
					if (x == 639 && y == 479) // increment counters reset horizontal line heplers
						begin
							VGA_timer <= VGA_timer + 1; // timer increment for fade in ( * VGA_timer/180/ )
							GND <= 0;
							L2_count <= 0;
							L3_count <= 0;
							L4_count <= 0;
							R2_count <= 0;
							R3_count <= 0;
							if (slide_timer > 0)
								begin
									slide_timer <= slide_timer - 2;
								end
						end
					if (x > 60 && x <= 600 && y > 31 && y <= 450 && ((x - 60 )% 120) < 60 && ((y - 30)% 280) < 140) //Draw Brown tiles
						begin
							if (VGA_timer > 1200)
								begin
									rgb[23:16] <= 8'h63 /4; rgb[15:8] <= 8'h32 /4; rgb[7:0] <= 8'h00 /4;
								end
							else if (VGA_timer > 600 && VGA_timer <= 1200)
								begin
									rgb[23:16] <= 8'h63  * (VGA_timer - 600)/600 /4; rgb[15:8] <= 8'h32  * (VGA_timer - 600)/600 /4; rgb[7:0] <= 8'h00   * (VGA_timer - 600)/600 /4;
								end
						end
					if (x > 60 && x <= 600 && y > 31 && y <= 450 && ((x - 60 )% 120) > 60 && ((y - 30)% 280) > 140) // Draw Grey tiles
						begin
							if(VGA_timer > 1200)
								begin
									rgb[23:16] <= 8'h33 /4; rgb[15:8] <= 8'h33 /4; rgb[7:0] <= 8'h33 /4;
								end
							else if (VGA_timer > 600 && VGA_timer <= 1200)
								begin
									rgb[23:16] <= 8'h33 * (VGA_timer - 600)/600 /4; rgb[15:8] <= 8'h33  * (VGA_timer - 600)/600 /4; rgb[7:0] <= 8'h33  * (VGA_timer - 600)/600/4;
								end
						end
					if (VGA_timer > 700 && x > 60 && x <= 119 && y > 7 && y <= 31) //Draw Checkerboard
						begin
							if ((y - 2) % 12 >= 6)
								begin
									if(((x - 60) % 12) >= 6)
										begin
											rgb[23:16] <= 8'hbb /4; rgb[15:8] <= 8'hbb /4; rgb[7:0] <= 8'hbb /4;
										end
									else
										begin
											rgb[23:16] <= 8'h03 /4; rgb[15:8] <= 8'h19 /4; rgb[7:0] <= 8'h1e /4;
										end
								end
							else
								begin
									if(((x - 60) % 12) >= 6)
										begin
											rgb[23:16] <= 8'h03 /4; rgb[15:8] <= 8'h19 /4; rgb[7:0] <= 8'h1e /4;
										end
									else
										begin
											rgb[23:16] <= 8'hbb /4; rgb[15:8] <= 8'hbb /4; rgb[7:0] <= 8'hbb /4;
										end
								end
						end
					if (VGA_timer > 700 && x > 1 && x <= 60 && y > 7 && y <= 67) //Draw Checkerboard
						begin
							if ((y - 2) % 12 >= 6)
								begin
									if(((x - 1) % 12) >= 6)
										begin
											rgb[23:16] <= 8'hbb /4; rgb[15:8] <= 8'hbb /4; rgb[7:0] <= 8'hbb /4;
										end
									else
										begin
											rgb[23:16] <= 8'h03 /4; rgb[15:8] <= 8'h19 /4; rgb[7:0] <= 8'h1e /4;
										end
								end
							else
								begin
									if(((x - 1) % 12) >= 6)
										begin
											rgb[23:16] <= 8'h03 /4; rgb[15:8] <= 8'h19 /4; rgb[7:0] <= 8'h1e /4;
										end
									else
										begin
											rgb[23:16] <= 8'hbb /4; rgb[15:8] <= 8'hbb /4; rgb[7:0] <= 8'hbb /4;
										end
								end
						end
					if (VGA_timer > 1200 && x > 539 && x <= 599 && y > 309 && y <= 450) // Draw green flag
						begin
							rgb[23:16] <= 8'h0e /4; rgb[15:8] <= 8'h65 /4; rgb[7:0] <= 8'h00 /4;
						end
					
//STart schematic (bottom to top order)---------------------------------------------------------------------------------------------
					if(VGA_timer > 30 && x > 553 + GND && x <= 593 - GND && y > 450 && y <= 470) //Draw Ground Symbol
						begin
							GND_current_y <= y;
							rgb[23:16] <= 8'hf2 /4;
							rgb[15:8] <= 8'hef /4;
							rgb[7:0] <= 8'hea /4;
							if (y != GND_current_y)
								GND <= GND + 1;		
						end
					if(VGA_timer > 60 && x > 570 && x <= 575  && y > 380 && y <= 450)
						begin
							rgb[23:16] <= 8'hf2 /4;
							rgb[15:8] <= 8'hef /4;
							rgb[7:0] <= 8'hea /4;
						end
					if(VGA_timer > 80 && x > 90 && x <= 570 && y > 380 && y <= 383)
						begin
							rgb[23:16] <= 8'hf2 /4;
							rgb[15:8] <= 8'hef /4;
							rgb[7:0] <= 8'hea /4;
						end
					if(VGA_timer > 180 && x > 90 && x <= 570 && y > 240 && y <= 243)
						begin
							rgb[23:16] <= 8'hf2 /4;
							rgb[15:8] <= 8'hef /4;
							rgb[7:0] <= 8'hea /4;
						end
					if(VGA_timer > 230 && x > 90 && x <= 570 && y > 100 && y <= 103)
						begin
							rgb[23:16] <= 8'hf2 /4;
							rgb[15:8] <= 8'hef /4;
							rgb[7:0] <= 8'hea /4;
						end
					if(VGA_timer > 250 && x > 90 && x <= 93 && y > 30 && y <= 100)
						begin
							rgb[23:16] <= 8'hf2 /4;
							rgb[15:8] <= 8'hef /4;
							rgb[7:0] <= 8'hea /4;
						end
					if(VGA_timer > 270 && x > 72 && x <= 112 && y > 27 && y <= 30)
						begin
							rgb[23:16] <= 8'hf2 /4;
							rgb[15:8] <= 8'hef /4;
							rgb[7:0] <= 8'hea /4;
						end
					if(VGA_timer > 270 && x > 80 && x <= 104 && y > 17 && y <= 20)
						begin
							rgb[23:16] <= 8'hf2 /4;
							rgb[15:8] <= 8'hef /4;
							rgb[7:0] <= 8'hea /4;
						end	
					if(VGA_timer > 270 && x > 85 && x <= 98 && y > 7 && y <= 10)
						begin
							rgb[23:16] <= 8'hf2 /4;
							rgb[15:8] <= 8'hef /4;
							rgb[7:0] <= 8'hea /4;
						end					
					if(VGA_timer > 300 && x > 30 && x <= 90 && y > 100 && y <= 103) // red wire top
						begin
							rgb[23:16] <= 8'hcc /4;
							rgb[15:8] <= 8'h5a /4;
							rgb[7:0] <= 8'h71 /4;
						end
					if(VGA_timer > 330 && x > 30 && x <= 35 && y > 100 && y <= 243) // red wire top
						begin
							rgb[23:16] <= 8'hcc /4;
							rgb[15:8] <= 8'h5a /4;
							rgb[7:0] <= 8'h71 /4;
						end
					if(VGA_timer > 370 && x > 30 && x <= 35 && y > 380 && y <= 438) // red wire top
						begin
							rgb[23:16] <= 8'hcc /4;
							rgb[15:8] <= 8'h5a /4;
							rgb[7:0] <= 8'h71 /4;
						end
					if(VGA_timer > 390 && x > 30 && x <= 570 && y > 435 && y <= 438) // red wire top
						begin
							rgb[23:16] <= 8'hcc /4;
							rgb[15:8] <= 8'h5a /4;
							rgb[7:0] <= 8'h71 /4;
						end
// L2 Start
					if(VGA_timer > 590)
						begin
							if(x > L2_x && x <= L2_x + 5 && y > L2_y && y <= L2_y + 30)
								begin
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
						end
					if(VGA_timer > 625)
						begin
							if(x > L2_x + L2_count && x <= L2_x + 5 + L2_count && y > L2_y + 30 && y <= L2_y + 35)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L2_current_y)
										L2_count <= L2_count + 2;
								end
							if(x > L2_x + L2_count && x <= L2_x + 5 + L2_count && y > L2_y + 35 && y <= L2_y + 40)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L2_current_y)
										L2_count <= L2_count + 1;
								end
							if(x > L2_x + L2_count && x <= L2_x + L2_count + 5 && y > L2_y + 40 && y <= L2_y + 45)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
							if(x > L2_x + L2_count && x <= L2_x + 5 + L2_count && y > L2_y + 45 && y <= L2_y + 50)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L2_current_y)
										L2_count <= L2_count - 1;
								end
							if(x > L2_x + L2_count && x <= L2_x + 5 + L2_count && y > L2_y + 50 && y <= L2_y + 55)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L2_current_y)
										L2_count <= L2_count - 2;
								end
						end
					if(VGA_timer > 650)
						begin
							if(x > L2_x + L2_count && x <= L2_x + 5 + L2_count && y > L2_y + 55 && y <= L2_y + 60)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L2_current_y)
										L2_count <= L2_count + 2;
								end
							if(x > L2_x + L2_count && x <= L2_x + 5 + L2_count && y > L2_y + 60 && y <= L2_y + 65)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L2_current_y)
										L2_count <= L2_count + 1;
								end
							if(x > L2_x + L2_count && x <= L2_x + L2_count + 5 && y > L2_y + 65 && y <= L2_y + 70)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
							if(x > L2_x + L2_count && x <= L2_x + 5 + L2_count && y > L2_y + 70 && y <= L2_y + 75)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L2_current_y)
										L2_count <= L2_count - 1;
								end
							if(x > L2_x + L2_count && x <= L2_x + 5 + L2_count && y > L2_y + 75 && y <= L2_y + 80)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L2_current_y)
										L2_count <= L2_count - 2;
								end
						end	
					if(VGA_timer > 680)
						begin
							if(x > L2_x + L2_count && x <= L2_x + 5 + L2_count && y > L2_y + 80 && y <= L2_y + 85)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L2_current_y)
										L2_count <= L2_count + 2;
								end
							if(x > L2_x + L2_count && x <= L2_x + 5 + L2_count && y > L2_y + 85 && y <= L2_y + 90)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L2_current_y)
										L2_count <= L2_count + 1;
								end
							if(x > L2_x + L2_count && x <= L2_x + L2_count + 5 && y > L2_y + 90 && y <= L2_y + 95)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
							if(x > L2_x + L2_count && x <= L2_x + 5 + L2_count && y > L2_y + 95 && y <= L2_y + 100)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L2_current_y)
										L2_count <= L2_count - 1;
								end
							if(x > L2_x + L2_count && x <= L2_x + 5 + L2_count && y > L2_y + 100 && y <= L2_y + 105)
								begin
									L2_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L2_current_y)
										L2_count <= L2_count - 2;
								end
						end
					if(VGA_timer > 700)
						begin
							if(x > L2_x && x <= L2_x + 5 && y > L2_y + 105 && y <= L2_y + 137)
								begin
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
						end
//L2 End
//L3 Begin
					if(VGA_timer > 410)
						begin
							if(x > L3_x && x <= L3_x + 5 && y > L3_y && y <= L3_y + 30)
								begin
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
						end
					if(VGA_timer > 430)
						begin
							if(x > L3_x + L3_count && x <= L3_x + 5 + L3_count && y > L3_y + 30 && y <= L3_y + 35)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L3_current_y)
										L3_count <= L3_count + 2;
								end
							if(x > L3_x + L3_count && x <= L3_x + 5 + L3_count && y > L3_y + 35 && y <= L3_y + 40)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L3_current_y)
										L3_count <= L3_count + 1;
								end
							if(x > L3_x + L3_count && x <= L3_x + L3_count + 5 && y > L3_y + 40 && y <= L3_y + 45)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
							if(x > L3_x + L3_count && x <= L3_x + 5 + L3_count && y > L3_y + 45 && y <= L3_y + 50)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L3_current_y)
										L3_count <= L3_count - 1;
								end
							if(x > L3_x + L3_count && x <= L3_x + 5 + L3_count && y > L3_y + 50 && y <= L3_y + 55)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L3_current_y)
										L3_count <= L3_count - 2;
								end
						end
					if(VGA_timer > 440)
						begin
							if(x > L3_x + L3_count && x <= L3_x + 5 + L3_count && y > L3_y + 55 && y <= L3_y + 60)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L3_current_y)
										L3_count <= L3_count + 2;
								end
							if(x > L3_x + L3_count && x <= L3_x + 5 + L3_count && y > L3_y + 60 && y <= L3_y + 65)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L3_current_y)
										L3_count <= L3_count + 1;
								end
							if(x > L3_x + L3_count && x <= L3_x + L3_count + 5 && y > L3_y + 65 && y <= L3_y + 70)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
							if(x > L3_x + L3_count && x <= L3_x + 5 + L3_count && y > L3_y + 70 && y <= L3_y + 75)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L3_current_y)
										L3_count <= L3_count - 1;
								end
							if(x > L3_x + L3_count && x <= L3_x + 5 + L3_count && y > L3_y + 75 && y <= L3_y + 80)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L3_current_y)
										L3_count <= L3_count - 2;
								end
						end	
					if(VGA_timer > 450)
						begin
							if(x > L3_x + L3_count && x <= L3_x + 5 + L3_count && y > L3_y + 80 && y <= L3_y + 85)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L3_current_y)
										L3_count <= L3_count + 2;
								end
							if(x > L3_x + L3_count && x <= L3_x + 5 + L3_count && y > L3_y + 85 && y <= L3_y + 90)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L3_current_y)
										L3_count <= L3_count + 1;
								end
							if(x > L3_x + L3_count && x <= L3_x + L3_count + 5 && y > L3_y + 90 && y <= L3_y + 95)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
							if(x > L3_x + L3_count && x <= L3_x + 5 + L3_count && y > L3_y + 95 && y <= L3_y + 100)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L3_current_y)
										L3_count <= L3_count - 1;
								end
							if(x > L3_x + L3_count && x <= L3_x + 5 + L3_count && y > L3_y + 100 && y <= L3_y + 105)
								begin
									L3_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L3_current_y)
										L3_count <= L3_count - 2;
								end
						end
					if(VGA_timer > 480)
						begin
							if(x > L3_x && x <= L3_x + 5 && y > L3_y + 105 && y <= L3_y + 137)
								begin
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
						end
//L3 End
//L4 Begin
					if(VGA_timer > 500)
						begin
							if(x > L4_x && x <= L4_x + 5 && y > L4_y && y <= L4_y + 30)
								begin
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
						end
					if(VGA_timer > 515)
						begin
							if(x > L4_x + L4_count && x <= L4_x + 5 + L4_count && y > L4_y + 30 && y <= L4_y + 35)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L4_current_y)
										L4_count <= L4_count + 2;
								end
							if(x > L4_x + L4_count && x <= L4_x + 5 + L4_count && y > L4_y + 35 && y <= L4_y + 40)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L4_current_y)
										L4_count <= L4_count + 1;
								end
							if(x > L4_x + L4_count && x <= L4_x + L4_count + 5 && y > L4_y + 40 && y <= L4_y + 45)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
							if(x > L4_x + L4_count && x <= L4_x + 5 + L4_count && y > L4_y + 45 && y <= L4_y + 50)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L4_current_y)
										L4_count <= L4_count - 1;
								end
							if(x > L4_x + L4_count && x <= L4_x + 5 + L4_count && y > L4_y + 50 && y <= L4_y + 55)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L4_current_y)
										L4_count <= L4_count - 2;
								end
						end
					if(VGA_timer > 540)
						begin
							if(x > L4_x + L4_count && x <= L4_x + 5 + L4_count && y > L4_y + 55 && y <= L4_y + 60)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L4_current_y)
										L4_count <= L4_count + 2;
								end
							if(x > L4_x + L4_count && x <= L4_x + 5 + L4_count && y > L4_y + 60 && y <= L4_y + 65)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L4_current_y)
										L4_count <= L4_count + 1;
								end
							if(x > L4_x + L4_count && x <= L4_x + L4_count + 5 && y > L4_y + 65 && y <= L4_y + 70)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
							if(x > L4_x + L4_count && x <= L4_x + 5 + L4_count && y > L4_y + 70 && y <= L4_y + 75)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L4_current_y)
										L4_count <= L4_count - 1;
								end
							if(x > L4_x + L4_count && x <= L4_x + 5 + L4_count && y > L4_y + 75 && y <= L4_y + 80)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L4_current_y)
										L4_count <= L4_count - 2;
								end
						end	
					if(VGA_timer > 560)
						begin
							if(x > L4_x + L4_count && x <= L4_x + 5 + L4_count && y > L4_y + 80 && y <= L4_y + 85)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L4_current_y)
										L4_count <= L4_count + 2;
								end
							if(x > L4_x + L4_count && x <= L4_x + 5 + L4_count && y > L4_y + 85 && y <= L4_y + 90)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L4_current_y)
										L4_count <= L4_count + 1;
								end
							if(x > L4_x + L4_count && x <= L4_x + L4_count + 5 && y > L4_y + 90 && y <= L4_y + 95)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
							if(x > L4_x + L4_count && x <= L4_x + 5 + L4_count && y > L4_y + 95 && y <= L4_y + 100)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L4_current_y)
										L4_count <= L4_count - 1;
								end
							if(x > L4_x + L4_count && x <= L4_x + 5 + L4_count && y > L4_y + 100 && y <= L4_y + 105)
								begin
									L4_current_y <= y;
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
									if (y!= L4_current_y)
										L4_count <= L4_count - 2;
								end
						end
					if(VGA_timer > 575)
						begin
							if(x > L4_x && x <= L4_x + 5 && y > L4_y + 105 && y <= L4_y + 137)
								begin
									rgb[23:16] <= 8'h91 /4; rgb[15:8] <= 8'hcb /4; rgb[7:0] <= 8'h3e /4;
								end
						end
//L4 End
//R2 Begin
					if(VGA_timer > 490)
						begin 
							if(x > R2_x && x <= R2_x + 5 && y > R2_y && y < R2_y + 30)
								begin
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
								end
							if (x > R2_x + R2_count && x <= R2_x + 5 + R2_count && y >= R2_y + 30 && y < R2_y + 40)
								begin
									R2_current_y <= y;
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
									if (y != R2_current_y)
										R2_count <= R2_count + 1;
								end
						end
					if(VGA_timer > 505)
						begin
							if (x > R2_x + R2_count && x <= R2_x + 5 + R2_count && y >= R2_y + 40 && y < R2_y + 60)
								begin
									R2_current_y <= y;
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
									if (y != R2_current_y)
										R2_count <= R2_count - 1;
								end
						end
					if(VGA_timer > 515)
						begin
							if (x > R2_x + R2_count && x <= R2_x + 5 + R2_count && y >= R2_y + 60 && y < R2_y + 80)
								begin
									R2_current_y <= y;
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
									if (y != R2_current_y)
										R2_count <= R2_count + 1;
								end
						end
					if(VGA_timer > 530)
						begin
							if (x > R2_x + R2_count && x <= R2_x + 5 + R2_count && y >= R2_y + 80 && y < R2_y + 100)
								begin
									R2_current_y <= y;
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
									if (y != R2_current_y)
										R2_count <= R2_count - 1;
								end
						end
					if(VGA_timer > 540)
						begin
							if (x > R2_x + R2_count && x <= R2_x + 5 + R2_count && y >= R2_y + 100 && y < R2_y + 110)
								begin
									R2_current_y <= y;
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
									if (y != R2_current_y)
										R2_count <= R2_count + 1;
								end
						end
					if(VGA_timer > 550)
						begin
							if(x > R2_x && x <= R2_x + 5 && y >= R2_y + 110 && y < R2_y + 138)
								begin
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
								end
						end
//R2 End
//R3 Begin
					if(VGA_timer > 560)
						begin 
							if(x > R3_x && x <= R3_x + 5 && y > R3_y && y < R3_y + 30)
								begin
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
								end
							if (x > R3_x + R3_count && x <= R3_x + 5 + R3_count && y >= R3_y + 30 && y < R3_y + 40)
								begin
									R3_current_y <= y;
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
									if (y != R3_current_y)
										R3_count <= R3_count + 1;
								end
						end
					if(VGA_timer > 575)
						begin
							if (x > R3_x + R3_count && x <= R3_x + 5 + R3_count && y >= R3_y + 40 && y < R3_y + 60)
								begin
									R3_current_y <= y;
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
									if (y != R3_current_y)
										R3_count <= R3_count - 1;
								end
						end
					if(VGA_timer > 590)
						begin
							if (x > R3_x + R3_count && x <= R3_x + 5 + R3_count && y >= R3_y + 60 && y < R3_y + 80)
								begin
									R3_current_y <= y;
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
									if (y != R3_current_y)
										R3_count <= R3_count + 1;
								end
						end
					if(VGA_timer > 600)
						begin
							if (x > R3_x + R3_count && x <= R3_x + 5 + R3_count && y >= R3_y + 80 && y < R3_y + 100)
								begin
									R3_current_y <= y;
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
									if (y != R3_current_y)
										R3_count <= R3_count - 1;
								end
						end
					if(VGA_timer > 615)
						begin
							if (x > R3_x + R3_count && x <= R3_x + 5 + R3_count && y >= R3_y + 100 && y < R3_y + 110)
								begin
									R3_current_y <= y;
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
									if (y != R3_current_y)
										R3_count <= R3_count + 1;
								end
						end
					if(VGA_timer > 625)
						begin
							if(x > R3_x && x <= R3_x + 5 && y >= R3_y + 110 && y < R3_y + 144)
								begin
									rgb[23:16] <= 8'hf2 /4; rgb[15:8] <= 8'hef /4; rgb[7:0] <= 8'hea /4;
								end
						end
//R4 end
//C2 begin
					if(VGA_timer > 450)
						begin
							if(x > C2_x && x <= C2_x + 5 && y > C2_y && y <= C2_y + 55)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 465)
						begin
							if(x >= C2_x - 15 && x < C2_x + 20 && y > C2_y + 55 && y <= C2_y + 60)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 480)
						begin
							if(x >= C2_x - 15 && x < C2_x + 20 && y > C2_y + 80 && y <= C2_y + 85)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end											
					if(VGA_timer > 495)
						begin
							if(x > C2_x && x <= C2_x + 5 && y > C2_y + 85 && y <= C2_y + 137)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
//C2 End
//C3 begin
					if(VGA_timer > 450)
						begin
							if(x > C3_x && x <= C3_x + 5 && y > C3_y && y <= C3_y + 55)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 465)
						begin
							if(x >= C3_x - 15 && x < C3_x + 20 && y > C3_y + 55 && y <= C3_y + 60)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 480)
						begin
							if(x >= C3_x - 15 && x < C3_x + 20 && y > C3_y + 80 && y <= C3_y + 85)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end											
					if(VGA_timer > 495)
						begin
							if(x > C3_x && x <= C3_x + 5 && y > C3_y + 85 && y <= C3_y + 137)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
//C3 End
//C4 begin
					if(VGA_timer > 450)
						begin
							if(x > C4_x && x <= C4_x + 5 && y > C4_y && y <= C4_y + 55)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 465)
						begin
							if(x >= C4_x - 15 && x < C4_x + 20 && y > C4_y + 55 && y <= C4_y + 60)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 480)
						begin
							if(x >= C4_x - 15 && x < C4_x + 20 && y > C4_y + 85 && y <= C4_y + 90)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end											
					if(VGA_timer > 495)
						begin
							if(x > C4_x && x <= C4_x + 5 && y > C4_y + 90 && y <= C4_y + 137)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
//C4 End
//C5 begin
					if(VGA_timer > 450)
						begin
							if(x > C5_x && x <= C5_x + 5 && y > C5_y && y <= C5_y + 55)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 465)
						begin
							if(x >= C5_x - 15 && x < C5_x + 20 && y > C5_y + 55 && y <= C5_y + 60)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 480)
						begin
							if(x >= C5_x - 15 && x < C5_x + 20 && y > C5_y + 80 && y <= C5_y + 85)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end											
					if(VGA_timer > 495)
						begin
							if(x > C5_x && x <= C5_x + 5 && y > C5_y + 85 && y <= C5_y + 137)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
//C5 End
//C6 begin
					if(VGA_timer > 450)
						begin
							if(x > C6_x && x <= C6_x + 5 && y > C6_y && y <= C6_y + 55)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 465)
						begin
							if(x >= C6_x - 15 && x < C6_x + 20 && y > C6_y + 55 && y <= C6_y + 60)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 480)
						begin
							if(x >= C6_x - 15 && x < C6_x + 20 && y > C6_y + 80 && y <= C6_y + 85)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end											
					if(VGA_timer > 495)
						begin
							if(x > C6_x && x <= C6_x + 5 && y > C6_y + 85 && y <= C6_y + 137)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
//C6 End
//C7 begin
					if(VGA_timer > 450)
						begin
							if(x > C7_x && x <= C7_x + 5 && y > C7_y && y <= C7_y + 55)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 465)
						begin
							if(x >= C7_x - 15 && x < C7_x + 20 && y > C7_y + 55 && y <= C7_y + 60)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 480)
						begin
							if(x >= C7_x - 15 && x < C7_x + 20 && y > C7_y + 80 && y <= C7_y + 85)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end											
					if(VGA_timer > 495)
						begin
							if(x > C7_x && x <= C7_x + 5 && y > C7_y + 85 && y <= C7_y + 137)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
//C7 End
//C8 begin
					if(VGA_timer > 450)
						begin
							if(x > C8_x && x <= C8_x + 5 && y > C8_y && y <= C8_y + 55)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 465)
						begin
							if(x >= C8_x - 15 && x < C8_x + 20 && y > C8_y + 55 && y <= C8_y + 60)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
					if(VGA_timer > 480)
						begin
							if(x >= C8_x - 15 && x < C8_x + 20 && y > C8_y + 80 && y <= C8_y + 85)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end											
					if(VGA_timer > 495)
						begin
							if(x > C8_x && x <= C8_x + 5 && y > C8_y + 85 && y <= C8_y + 137)
								begin
									rgb[23:16] <= 8'hcc /4; rgb[15:8] <= 8'h5a /4; rgb[7:0] <= 8'h71 /4;
								end
						end
//C8 End

						
//					if(VGA_timer > 410 && x > 530 && x <= 533 && y > 445 && y <= 460) // red wire top
//						begin
//							rgb[23:16] <= 8'hcc /4;
//							rgb[15:8] <= 8'h5a /4;
//							rgb[7:0] <= 8'h71 /4;
//						end
//					if(VGA_timer > 440 && x > 530 && x <= 570 && y > 445 && y <= 448) // red wire bot
//						begin
//							rgb[23:16] <= 8'hcc /4;
//							rgb[15:8] <= 8'h5a /4;
//							rgb[7:0] <= 8'h71 /4;
//						end
//Draw Squares +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Draw electron begin
					if (VGA_timer > 1250)
						begin
					// Electron 1
							if(x > (e1_x - ((e1_x - last_e1_x) * slide_timer)/120) && x < (e1_x + 5 - ((e1_x - last_e1_x) * slide_timer)/120)  && y >  (e1_y - ((e1_y - last_e1_y) * slide_timer)/120) && y <= (e1_y + 40 - ((e1_y - last_e1_y) * slide_timer)/120))
								begin
									rgb[23:16] <= 8'h44 /4; rgb[15:8] <= 8'hcc /4; rgb[7:0] <= 8'hff /4;
								end
							if(x > (e1_x - ((e1_x - last_e1_x) * slide_timer)/120) && x < (e1_x + 30 - ((e1_x - last_e1_x) * slide_timer)/120)  && y >  (e1_y - ((e1_y - last_e1_y) * slide_timer)/120) && y <= (e1_y + 5 - ((e1_y - last_e1_y) * slide_timer)/120))
								begin
									rgb[23:16] <= 8'h44 /4; rgb[15:8] <= 8'hcc /4; rgb[7:0] <= 8'hff /4;
								end
							if(x > (e1_x + 20 - ((e1_x - last_e1_x) * slide_timer)/120) && x < (e1_x + 30 - ((e1_x - last_e1_x) * slide_timer)/120)  && y >  (e1_y - ((e1_y - last_e1_y) * slide_timer)/120) && y <= (e1_y + 20 - ((e1_y - last_e1_y) * slide_timer)/120))
								begin
									rgb[23:16] <= 8'h44 /4; rgb[15:8] <= 8'hcc /4; rgb[7:0] <= 8'hff /4;
								end
							if(x > (e1_x - ((e1_x - last_e1_x) * slide_timer)/120) && x < (e1_x + 30 - ((e1_x - last_e1_x) * slide_timer)/120)  && y >  (e1_y + 15 - ((e1_y - last_e1_y) * slide_timer)/120) && y <= (e1_y + 20 - ((e1_y - last_e1_y) * slide_timer)/120))
								begin
									rgb[23:16] <= 8'h44  /4; rgb[15:8] <= 8'hcc /4; rgb[7:0] <= 8'hff /4;
								end
							if(x > (e1_x - ((e1_x - last_e1_x) * slide_timer)/120) && x < (e1_x + 30 - ((e1_x - last_e1_x) * slide_timer)/120)  && y >  (e1_y + 35 - ((e1_y - last_e1_y) * slide_timer)/120) && y <= (e1_y + 40 - ((e1_y - last_e1_y) * slide_timer)/120))
								begin
									rgb[23:16] <= 8'h44 /4; rgb[15:8] <= 8'hcc /4; rgb[7:0] <= 8'hff /4;
								end
							if(x > (e1_x + 35 - ((e1_x - last_e1_x) * slide_timer)/120) && x < (e1_x + 50 - ((e1_x - last_e1_x) * slide_timer)/120)  && y >  (e1_y - 5 - ((e1_y - last_e1_y) * slide_timer)/120) && y <= (e1_y - ((e1_y - last_e1_y) * slide_timer)/120))
								begin
									rgb[23:16] <= 8'h44 /4; rgb[15:8] <= 8'hcc /4; rgb[7:0] <= 8'hff /4;
								end
					// Electron 2
							if(x > (e2_x - ((e2_x - last_e2_x) * slide_timer)/120) && x < (e2_x + 5 - ((e2_x - last_e2_x) * slide_timer)/120)  && y >  (e2_y - ((e2_y - last_e2_y) * slide_timer)/120) && y <= (e2_y + 40 - ((e2_y - last_e2_y) * slide_timer)/120))
								begin
									rgb[23:16] <= 8'hff /4; rgb[15:8] <= 8'ha2 /4; rgb[7:0] <= 8'h20 /4;
								end
							if(x > (e2_x - ((e2_x - last_e2_x) * slide_timer)/120) && x < (e2_x + 30 - ((e2_x - last_e2_x) * slide_timer)/120)  && y >  (e2_y - ((e2_y - last_e2_y) * slide_timer)/120) && y <= (e2_y + 5 - ((e2_y - last_e2_y) * slide_timer)/120))
								begin
									rgb[23:16] <= 8'hff /4; rgb[15:8] <= 8'ha2 /4; rgb[7:0] <= 8'h20  /4;
								end
							if(x > (e2_x + 20 - ((e2_x - last_e2_x) * slide_timer)/120) && x < (e2_x + 30 - ((e2_x - last_e2_x) * slide_timer)/120)  && y >  (e2_y - ((e2_y - last_e2_y) * slide_timer)/120) && y <= (e2_y + 20 - ((e2_y - last_e2_y) * slide_timer)/120))
								begin
									rgb[23:16] <= 8'hff /4; rgb[15:8] <= 8'ha2 /4; rgb[7:0] <= 8'h20 /4;
								end
							if(x > (e2_x - ((e2_x - last_e2_x) * slide_timer)/120) && x < (e2_x + 30 - ((e2_x - last_e2_x) * slide_timer)/120)  && y >  (e2_y + 15 - ((e2_y - last_e2_y) * slide_timer)/120) && y <= (e2_y + 20 - ((e2_y - last_e2_y) * slide_timer)/120))
								begin
									rgb[23:16] <= 8'hff /4; rgb[15:8] <= 8'ha2 /4; rgb[7:0] <= 8'h20 /4;
								end
							if(x > (e2_x - ((e2_x - last_e2_x) * slide_timer)/120) && x < (e2_x + 30 - ((e2_x - last_e2_x) * slide_timer)/120)  && y >  (e2_y + 35 - ((e2_y - last_e2_y) * slide_timer)/120) && y <= (e2_y + 40 - ((e2_y - last_e2_y) * slide_timer)/120))
								begin
									rgb[23:16] <= 8'hff /4; rgb[15:8] <= 8'ha2 /4; rgb[7:0] <= 8'h20 /4;
								end
							if(x > (e2_x + 35 - ((e2_x - last_e2_x) * slide_timer)/120) && x < (e2_x + 50 - ((e2_x - last_e2_x) * slide_timer)/120)  && y >  (e2_y - 5 - ((e2_y - last_e2_y) * slide_timer)/120) && y <= (e2_y - ((e2_y - last_e2_y) * slide_timer)/120))
								begin
									rgb[23:16] <= 8'hff /4; rgb[15:8] <= 8'ha2 /4; rgb[7:0] <= 8'h20  /4;
								end
						end
					if (schematicStart == 0)
						begin
							schematicStart <= 1;
							VGA_timer <= 0;
							rgb[23:16] <= 8'h03 /4;
							rgb[15:8] <= 8'h19 /4;
							rgb[7:0] <= 8'h1e /4;
						end
					
				end
//DRAW SCHEMATIC END ------------------------------------------------------------------------------------------------------			
			
// DRAW MENU SCREEN START +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			if(reset == 1 || VGA_RLC_out[0] == 0) // Draw menu
				begin
					if(menuStart == 0)
						begin
							menuStart <= 1;
							VGA_timer <= 0;
						end
					if(reset == 1)
						begin
							VGA_timer <= 0;
							rgb[23:16] <= 8'h03/4; //r fade
							rgb[15:8] <= 8'h19/4; //g fade
							rgb[7:0] <= 8'h1e/4;	//b fade
						end
					else
						begin
							if (x == 639 && y == 479) // increment counters reset horizontal line heplers
								begin
									schematicStart <= 0;
									VGA_timer <= VGA_timer + 1; // timer increment for fade in
									R1_1_d <= 0;
									L1_1 <= 0;
								end
		//Begin Boarder Fade --------------------------------------------------------------------------
							if (VGA_timer < 180)
								begin
									if (x < 10 || x > 630 || y < 10 || y > 470)
										begin
											//rgb <= 24'hff_ff_ff * VGA_timer/150000000;
											rgb[23:16] <= 8'hcc * VGA_timer/180/4; //r fade
											rgb[15:8] <= 8'h5a * VGA_timer/180/4; //g fade
											rgb[7:0] <= 8'h71 * VGA_timer/180/4;	//b fade
										end
									else		
										begin
											rgb[23:16] <= 8'h03/4; //r fade
											rgb[15:8] <= 8'h19/4; //g fade
											rgb[7:0] <= 8'h1e/4;	//b fade
										end
									if (x < 5 || x > 634 || y < 5 || y > 474)
										begin
											rgb[23:16] <= 8'hf2 * VGA_timer/180/4; //r fade
											rgb[15:8] <= 8'hef * VGA_timer/180/4; //g fade
											rgb[7:0] <= 8'hea * VGA_timer/180/4;	//b fade
										end
								end
							else
								begin
									if (x < 10 || x > 630 || y < 10 || y > 470)
										begin
											rgb[23:16] <= 8'hcc/4;
											rgb[15:8] <= 8'h5a/4;
											rgb[7:0] <= 8'h71/4;
										end
									else
										begin
											rgb[23:16] <= 8'h03/4;
											rgb[15:8] <= 8'h19/4;
											rgb[7:0] <= 8'h1e/4;
										end
									if (x < 5 || x > 634 || y < 5 || y > 474)
										begin
											rgb[23:16] <= 8'hf2 /4;
											rgb[15:8] <= 8'hef /4;
											rgb[7:0] <= 8'hea /4;
										end

								end
							if(VGA_timer > 180)
								begin
			//draw resistor -----------------------------------------------
									if(VGA_timer > 240)
										begin 
											if(x > 200 && x < 205 && y > 80 && y < 120)
												begin
													rgb[23:16] <= 8'hf2 /4;
													rgb[15:8] <= 8'hef /4;
													rgb[7:0] <= 8'hea /4;
												end
											if (x > 200 + R1_1_d && x< 205 + R1_1_d && y >= 120 && y < 130)
												begin
													R1_current_y <= y;
													rgb[23:16] <= 8'hf2 /4;
													rgb[15:8] <= 8'hef /4;
													rgb[7:0] <= 8'hea /4;
													if (y != R1_current_y)
														R1_1_d <= R1_1_d + 1;
												end
										end
									if(VGA_timer > 290)
										begin
											if (x > 200 + R1_1_d && x < 205 + R1_1_d && y >= 130 && y < 150)
												begin
													R1_current_y <= y;
													rgb[23:16] <= 8'hf2 /4;
													rgb[15:8] <= 8'hef /4;
													rgb[7:0] <= 8'hea /4;
													if (y != R1_current_y)
														R1_1_d <= R1_1_d - 1;
												end
										end
									if(VGA_timer > 340)
										begin
											if (x > 200 + R1_1_d && x < 205 + R1_1_d && y >= 150 && y < 170)
												begin
													R1_current_y <= y;
													rgb[23:16] <= 8'hf2 /4;
													rgb[15:8] <= 8'hef /4;
													rgb[7:0] <= 8'hea /4;
													if (y != R1_current_y)
														R1_1_d <= R1_1_d + 1;
												end
										end
									if(VGA_timer > 370)
										begin
											if (x > 200 + R1_1_d && x < 205 + R1_1_d && y >= 170 && y < 190)
												begin
													R1_current_y <= y;
													rgb[23:16] <= 8'hf2 /4;
													rgb[15:8] <= 8'hef /4;
													rgb[7:0] <= 8'hea /4;
													if (y != R1_current_y)
														R1_1_d <= R1_1_d - 1;
												end
										end
									if(VGA_timer > 400)
										begin
											if (x > 200 + R1_1_d && x < 205 + R1_1_d && y >= 190 && y < 200)
												begin
													R1_current_y <= y;
													rgb[23:16] <= 8'hf2 /4;
													rgb[15:8] <= 8'hef /4;
													rgb[7:0] <= 8'hea /4;
													if (y != R1_current_y)
														R1_1_d <= R1_1_d + 1;
												end
										end
									if(VGA_timer > 400)
										begin
											if(x > 200 && x < 205 && y >= 200 && y < 240)
												begin
													rgb[23:16] <= 8'hf2 /4;
													rgb[15:8] <= 8'hef /4;
													rgb[7:0] <= 8'hea /4;
												end
										end
	// Draw Capacitor -----------------------------------------------------------------
									if(VGA_timer > 450)
										begin
											if(x > 400 && x < 405 && y > 80 && y <= 140)
												begin
													rgb[23:16] <= 8'hcc /4;
													rgb[15:8] <= 8'h5a /4;
													rgb[7:0] <= 8'h71 /4;
												end
										end
									if(VGA_timer > 480)
										begin
											if(x >= 385 && x < 420 && y > 140 && y <= 145)
												begin
													rgb[23:16] <= 8'hcc /4;
													rgb[15:8] <= 8'h5a /4;
													rgb[7:0] <= 8'h71 /4;
												end
										end
									if(VGA_timer > 530)
										begin
											if(x >= 385 && x < 420 && y > 175 && y <= 180)
												begin
													rgb[23:16] <= 8'hcc /4;
													rgb[15:8] <= 8'h5a /4;
													rgb[7:0] <= 8'h71 /4;
												end
										end											
									if(VGA_timer > 560)
										begin
											if(x > 400 && x < 405 && y > 180 && y <= 240)
												begin
													rgb[23:16] <= 8'hcc /4;
													rgb[15:8] <= 8'h5a /4;
													rgb[7:0] <= 8'h71 /4;
												end
										end
	// Draw Inductor -------------------------------------------------------------
									if(VGA_timer > 590)
										begin
											if(x > 300 && x < 305 && y > 80 && y <= 122)
												begin
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
												end
										end
									if(VGA_timer > 625)
										begin
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 122 && y <= 127)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
													if (y!= L1_current_y)
														L1_1 <= L1_1 + 2;
												end
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 127 && y <= 132)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
													if (y!= L1_current_y)
														L1_1 <= L1_1 + 1;
												end
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 132 && y <= 137)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
												end
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 137 && y <= 142)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
													if (y!= L1_current_y)
														L1_1 <= L1_1 - 1;
												end
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 142 && y <= 147)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
													if (y!= L1_current_y)
														L1_1 <= L1_1 - 2;
												end
										end
									if(VGA_timer > 650)
										begin
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 147 && y <= 152)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
													if (y!= L1_current_y)
														L1_1 <= L1_1 + 2;
												end
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 152 && y <= 157)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
													if (y!= L1_current_y)
														L1_1 <= L1_1 + 1;
												end
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 157 && y <= 162)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
												end
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 162 && y <= 167)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
													if (y!= L1_current_y)
														L1_1 <= L1_1 - 1;
												end
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 167 && y <= 172)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
													if (y!= L1_current_y)
														L1_1 <= L1_1 - 2;
												end
										end	
									if(VGA_timer > 680)
										begin
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 172 && y <= 177)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
													if (y!= L1_current_y)
														L1_1 <= L1_1 + 2;
												end
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 177 && y <= 182)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
													if (y!= L1_current_y)
														L1_1 <= L1_1 + 1;
												end
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 182 && y <= 187)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
												end
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 187 && y <= 192)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
													if (y!= L1_current_y)
														L1_1 <= L1_1 - 1;
												end
											if(x > 300 + L1_1 && x < 305 + L1_1 && y > 192 && y <= 197)
												begin
													L1_current_y <= y;
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
													if (y!= L1_current_y)
														L1_1 <= L1_1 - 2;
												end
										end										
									if(VGA_timer > 700)
										begin
											if(x > 300 && x < 305 && y > 197 && y <= 240)
												begin
													rgb[23:16] <= 8'h91 /4;
													rgb[15:8] <= 8'hcb /4;
													rgb[7:0] <= 8'h3e /4;
												end
										end	
								end
		// Draw e-    -----------------------------------------------------------
							if(VGA_timer > 730) // 44ccff blue color
								begin
									//draw 1st Electron
									if(x > 290 && x < 295 && y > 320 && y <= 360)
										begin
											rgb[23:16] <= 8'h44 /4;
											rgb[15:8] <= 8'hcc /4;
											rgb[7:0] <= 8'hff /4;
										end
									if(x > 290 && x < 320 && y > 320 && y <= 325)
										begin
											rgb[23:16] <= 8'h44 /4;
											rgb[15:8] <= 8'hcc /4;
											rgb[7:0] <= 8'hff /4;
										end
									if(x > 310 && x < 320 && y > 320 && y <= 340)
										begin
											rgb[23:16] <= 8'h44 /4;
											rgb[15:8] <= 8'hcc /4;
											rgb[7:0] <= 8'hff /4;
										end
									if(x > 290 && x < 320 && y > 335 && y <= 340)
										begin
											rgb[23:16] <= 8'h44 /4;
											rgb[15:8] <= 8'hcc /4;
											rgb[7:0] <= 8'hff /4;
										end
									if(x > 290 && x < 320 && y > 355 && y <= 360)
										begin
											rgb[23:16] <= 8'h44 /4;
											rgb[15:8] <= 8'hcc /4;
											rgb[7:0] <= 8'hff /4;
										end
									if(x > 325 && x < 340 && y > 315 && y <= 320)
										begin
											rgb[23:16] <= 8'h44 /4;
											rgb[15:8] <= 8'hcc /4;
											rgb[7:0] <= 8'hff /4;
										end
									// draw 1st Electron END --------------------------------
									// Draw 1 ---------------
									if(x > 242 && x < 252 && y > 320 && y <= 360)
										begin
											rgb[23:16] <= 8'hf2 /4;
											rgb[15:8] <= 8'hef /4;
											rgb[7:0] <= 8'hea /4;
										end
									if(x > 235 && x < 260 && y > 320 && y <= 325)
										begin
											rgb[23:16] <= 8'hf2 /4;
											rgb[15:8] <= 8'hef /4;
											rgb[7:0] <= 8'hea /4;
										end
									if(x > 235 && x < 260 && y > 355 && y <= 360)
										begin
											rgb[23:16] <= 8'hf2 /4;
											rgb[15:8] <= 8'hef /4;
											rgb[7:0] <= 8'hea /4;
										end
									if (VGA_RLC_out[1] == 1'b1) // 1 SOC gameplay WHITE: f2efea orange: ffa220
										begin
										//draw 2nd electron ---------------------------------
											if(x > 290 + 60 && x < 295 + 60  && y > 320 && y <= 360)
												begin
													rgb[23:16] <= 8'hff /4;
													rgb[15:8] <= 8'ha2 /4;
													rgb[7:0] <= 8'h20 /4;
												end
											if(x > 290 + 60  && x < 320 + 60  && y > 320 && y <= 325)
												begin
													rgb[23:16] <= 8'hff /4;
													rgb[15:8] <= 8'ha2 /4;
													rgb[7:0] <= 8'h20 /4;
												end
											if(x > 310 + 60  && x < 320 + 60  && y > 320 && y <= 340)
												begin
													rgb[23:16] <= 8'hff /4;
													rgb[15:8] <= 8'ha2 /4;
													rgb[7:0] <= 8'h20 /4;
												end
											if(x > 290 + 60  && x < 320 + 60  && y > 335 && y <= 340)
												begin
													rgb[23:16] <= 8'hff /4;
													rgb[15:8] <= 8'ha2 /4;
													rgb[7:0] <= 8'h20 /4;
												end
											if(x > 290 + 60  && x < 320 + 60  && y > 355 && y <= 360)
												begin
													rgb[23:16] <= 8'hcc /4;
													rgb[23:16] <= 8'hff /4;
													rgb[15:8] <= 8'ha2 /4;
													rgb[7:0] <= 8'h20 /4;
												end
											if(x > 325 + 60  && x < 340 + 60  && y > 315 && y <= 320)
												begin
													rgb[23:16] <= 8'hff /4;
													rgb[15:8] <= 8'ha2 /4;
													rgb[7:0] <= 8'h20 /4;
												end
											//Second electron end -------------------------------
										end
									else
										begin
										//draw 2nd electron ---------------------------------
											if(x > 290 && x < 295  && y > 320 + 60 && y <= 360 + 60)
												begin
													rgb[23:16] <= 8'hff /4;
													rgb[15:8] <= 8'ha2 /4;
													rgb[7:0] <= 8'h20 /4;
												end
											if(x > 290 && x < 320 && y > 320 + 60 && y <= 325 + 60)
												begin
													rgb[23:16] <= 8'hff /4;
													rgb[15:8] <= 8'ha2 /4;
													rgb[7:0] <= 8'h20 /4;
												end
											if(x > 310 && x < 320 && y > 320 + 60 && y <= 340 + 60)
												begin
													rgb[23:16] <= 8'hff /4;
													rgb[15:8] <= 8'ha2 /4;
													rgb[7:0] <= 8'h20 /4;
												end
											if(x > 290 && x < 320 && y > 335 + 60&& y <= 340 + 60)
												begin
													rgb[23:16] <= 8'hff /4;
													rgb[15:8] <= 8'ha2 /4;
													rgb[7:0] <= 8'h20 /4;
												end
											if(x > 290 && x < 320 && y > 355 + 60 && y <= 360 + 60)
												begin
													rgb[23:16] <= 8'hff /4;
													rgb[15:8] <= 8'ha2 /4;
													rgb[7:0] <= 8'h20 /4;
												end
											if(x > 325 && x < 340 && y > 315 + 60 && y <= 320 + 60)
												begin
													rgb[23:16] <= 8'hff /4;
													rgb[15:8] <= 8'ha2 /4;
													rgb[7:0] <= 8'h20 /4;
												end
											//Second electron end -------------------------------
											//Draw 2 // y: 380-420
											if(x > 250 && x < 260 && y > 380 && y <= 420)
												begin
													rgb[23:16] <= 8'hf2 /4;
													rgb[15:8] <= 8'hef /4;
													rgb[7:0] <= 8'hea /4;
												end
											if(x > 235 && x < 245 && y > 380 && y <= 420)
												begin
													rgb[23:16] <= 8'hf2 /4;
													rgb[15:8] <= 8'hef /4;
													rgb[7:0] <= 8'hea /4;
												end
											if(x > 225 && x < 270 && y > 380 && y <= 385)
												begin
													rgb[23:16] <= 8'hf2 /4;
													rgb[15:8] <= 8'hef /4;
													rgb[7:0] <= 8'hea /4;
												end
											if(x > 225 && x < 270 && y > 415 && y <= 420)
												begin
													rgb[23:16] <= 8'hf2 /4;
													rgb[15:8] <= 8'hef /4;
													rgb[7:0] <= 8'hea /4;
												end
										end
								end	
						end
				end
// DRAW MENU SCREEN END ------------------------------------------------------------------------------------------
		end
	
	always_ff @(posedge CLOCK_50) //Output Data FF
		begin
			if (reset) // initialize program state
				begin
					outputClock <= 0;
					outputData <= 0;
					dataTransferEnable <= 0;
					dataTransferCounter <= 0;
					//dataStoreEnable <= 0;
					HEX1 <= ~7'b0;
					HEX2 <= ~7'b0;
					HEX3 <= ~7'b0;
					HEX4 <= ~7'b0;
					HEX5 <= ~7'b0;
				end
			// BEGIN -- DATA OUT CONTROL  BLOCK --------------------------------------------------------------------
			if (outputClockEnable == 1 && dataTransferEnable == 0) // check to begin serial data transfer
				begin
					dataTransferEnable <= 1;
					dataTransferCounter <= 0;
					outputClock <= 0;
				end
			if (dataTransferEnable == 1) // Data transfer control
				begin
					if (outputClock == 0 && dataTransferCounter < 8) //if Clock is low, then increment beginTransferByte and send data next clock cycle
						begin
							outputClock <= 1;
							outputData <= beginTransferByte[dataTransferCounter];
							dataTransferCounter <= dataTransferCounter + 1;
						end
					else if (outputClock == 1 && dataTransferCounter < 8) // if clock is high, make clock low
						outputClock <= 0;
					if (outputClock == 0 && 8 <= dataTransferCounter && dataTransferCounter <= 15) ///if Clock is low, then increment data array and send data next clock cycle
						begin
							outputClock <= 1;
							outputData <= dataOutArray[dataTransferCounter - 8];
							dataTransferCounter <= dataTransferCounter + 1;
						end
					else if (outputClock == 1 && 8 <= dataTransferCounter && dataTransferCounter <= 15) // if clock is high, make clock low
						outputClock <= 0;
					if (16 <= dataTransferCounter) // end data transfer
						begin
							outputClock <= 0;
							if (outputClockEnable == 0) // if output enable bit is toggled, then allow another transfer
								begin
									dataTransferEnable <= 0;	
									dataTransferCounter <= 0;
								end
						end
				end
			// END -- DATA OUT CONTROL BLOCK *********************************************************************
		end
	always_ff @(posedge inputClock) //input Data FF
		begin
			// BEGIN -- DATA IN CONTROL BLOCK --------------------------------------------------------------------
			if (dataStoreEnable == 0) // State Machine to check for data transfer start bit
				begin
					if (dataInState == 0) // data in counter keeps state position // RESET state
						begin
							dataInCounter2 <= 0;
							if (inputData == 1)
								dataInState <= 0;
							if (inputData == 0)
								dataInState <= 1;
						end
					if (dataInState == 1) // 0
						begin
							if (inputData == 1)
								dataInState <= 0;
							if (inputData == 0)
								dataInState <= 2;
						end
					if (dataInState == 2) //00
						begin
							if (inputData == 1)
								dataInState <= 0;
							if (inputData == 0)
								dataInState <= 3;
						end						
					if (dataInState == 3) // 000
						begin
							if (inputData == 1)
								dataInState <= 0;
							if (inputData == 0)
								dataInState <= 4;
						end						
					if (dataInState == 4) // 0000
						begin
							if (inputData == 1)
								dataInState <= 5;
							if (inputData == 0)
								dataInState <= 4;
						end
					if (dataInState == 5) // 10000
						begin
							if (inputData == 1)
								dataInState <= 6;
							if (inputData == 0)
								dataInState <= 0;
						end
					if (dataInState == 6) //110000
						begin
							if (inputData == 1)
								dataInState <= 7;
							if (inputData == 0)
								dataInState <= 0;
						end
					if (dataInState == 7) //1110000
						begin
							if (inputData == 1)
								dataStoreEnable <= 1;
							if (inputData == 0)
								dataInState <= 0;
						end
				end
			if (dataStoreEnable == 1)	
				begin
					dataInArray[dataInCounter2] <= inputData;
					dataInCounter2 <= dataInCounter2 + 1;
					if (dataInCounter2 == 7)
						begin
							dataStoreEnable <= 0;
							dataInState <= 0;
						end
				end
			// END -- DATA IN CONTROL BLOCK ************************************************************************
		end
	
endmodule
