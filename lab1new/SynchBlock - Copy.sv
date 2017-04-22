// Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, the Altera Quartus II License Agreement,
// the Altera MegaCore Function License Agreement, or other 
// applicable license agreement, including, without limitation, 
// that your use is for the sole purpose of programming logic 
// devices manufactured by Altera and sold by Altera or its 
// authorized distributors.  Please refer to the applicable 
// agreement for further details.

// PROGRAM		"Quartus II 64-Bit"
// VERSION		"Version 14.0.0 Build 200 06/17/2014 SJ Web Edition"
// CREATED		"Fri Apr 21 03:18:23 2017"

module SynchBlockCounter(
	CLOCK_50,
	LEDR,
	KEY
);


wire	Vcc;
wire	reset;
input logic CLOCK_50;
input logic [3:0]KEY;
wire	out0;
wire	out1;
wire	out2;
reg	out3;
output logic [3:0]LEDR;

//clock divider stuff
logic [31:0] clk;
parameter whichClock = 24;
clock_divider cdiv (CLOCK_50, clk);

assign LEDR = {out3,out2,out1,out0};
assign reset = KEY[0];
assign Vcc = 1'b1;

reg	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;
reg	JKFF_inst1;
reg	JKFF_inst2;

assign	out0 = SYNTHESIZED_WIRE_5;
assign	out1 = JKFF_inst1;
assign	out2 = JKFF_inst2;

always@(posedge CLOCK_50 or negedge reset)
begin
if (!reset)
	begin
	SYNTHESIZED_WIRE_5 <= 0;
	end
else
	begin
	SYNTHESIZED_WIRE_5 <= ~SYNTHESIZED_WIRE_5 & Vcc | SYNTHESIZED_WIRE_5 & ~Vcc;
	end
end


always@(posedge CLOCK_50 or negedge reset)
begin
if (!reset)
	begin
	JKFF_inst1 <= 0;
	end
else
	begin
	JKFF_inst1 <= ~JKFF_inst1 & SYNTHESIZED_WIRE_5 | JKFF_inst1 & ~SYNTHESIZED_WIRE_5;
	end
end


always@(posedge CLOCK_50 or negedge reset)
begin
if (!reset)
	begin
	JKFF_inst2 <= 0;
	end
else
	begin
	JKFF_inst2 <= ~JKFF_inst2 & SYNTHESIZED_WIRE_6 | JKFF_inst2 & ~SYNTHESIZED_WIRE_6;
	end
end


always@(posedge CLOCK_50 or negedge reset)
begin
if (!reset)
	begin
	out3 <= 0;
	end
else
	begin
	out3 <= ~out3 & SYNTHESIZED_WIRE_7 | out3 & ~SYNTHESIZED_WIRE_7;
	end
end

assign	SYNTHESIZED_WIRE_6 = SYNTHESIZED_WIRE_5 & JKFF_inst1;

assign	SYNTHESIZED_WIRE_7 = SYNTHESIZED_WIRE_6 & JKFF_inst2;

endmodule

module SynchBlockCounter_testbench();

	logic clk; 
	logic [3:0]KEY, LEDR;

	SynchBlockCounter dut (.CLOCK_50(clk), .KEY, .LEDR);

// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;	
	end
	
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
									@(posedge clk);
		KEY[0] <= 0; 			@(posedge clk);
		KEY[0] <= 1; 			@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									
		$stop; // End the simulation.
	end

endmodule