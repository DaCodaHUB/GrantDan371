module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	input  		 CLOCK_50; //50MHz clock
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output [9:0] LEDR;
	input  [3:0] KEY;
	input  [9:0] SW;
	
	// Generate clk off of CLOCK_50, whichClock picks rate
	wire [31:0] clk;
	parameter whichClock = 25;
	clock_divider cdiv (CLOCK_50, clk);
	
	// Hook up FSM inputs and outputs
	wire reset;
	wire [3:0] out;
	assign reset = SW[0];		// Reset when SW[0] is switched on
	
	//RDown_Counter Counter1 (clk[whichClock], reset, out); //Ripple down counter
	//SyncUpCount Counter2 (clk[whichClock], reset, out); //Sync up counter
	JohnsonCount Counter3 (out, clk[whichClock], reset); //Sync Johnson counter
	//UpCounter Counter4 (clk[whichClock], reset, out); //schematic up counter
	
	// Show signals on LEDRs
	assign LEDR [3:0] = out;

endmodule

// divided_clocks[0] = 25MHz, [1] = 12.5MHz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75 Hz, ...
module clock_divider (clock, divided_clocks); 
	input				clock;
	output reg [31:0]	divided_clocks;
	
	initial
		divided_clocks <= 32'b0;
	
	always@(posedge clock)
		divided_clocks <= divided_clocks + 1;
endmodule

/*
	building a system timebase from one of the de1 board built in clocks.
	



module MyModule(stuff, iClk, reset);

	input stuff;                            		// input stuff
	input iClk;                             		// system clock, 50 MHz for example
	input reset;                            		// active low reset

	reg [21:0]  tBase;								// system timebase


	always@(posedge iClk) tBase <= tBase + 1'b1; 	//  build the timebase

	other stuff

	DF FF0(q0, nq0, d0, tBase[18], reset);			//  uses system clock / 2^18

	more stuff

endmodule*/
