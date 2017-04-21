//----------------------------------
//Module: DE1_SoC
//Designed by: Grant Maiden, Dang Le
//Purpose: DFF for 371 labs
//----------------------------------


module DE1_SoC (CLOCK_50, SW, LEDR);
	input CLOCK_50;  // 50MHz clock.
	input [9:0] SW;
	output [3:0] LEDR;
	
	// Generate clk off of CLOCK_50, whichClock picks rate.
	wire [31:0] clk;
	parameter whichClock = 0;
	clock_divider cdiv (CLOCK_50, clk);
	
	RippleUp r1 (.Clk(clk[whichClock]), .Reset(SW[9]), .out(LEDR));
endmodule
