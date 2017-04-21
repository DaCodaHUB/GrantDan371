module SynchUpCounter (CLOCK_50, KEY, LEDR);
	input logic CLOCK_50;
	input logic [3:0]KEY;
	output logic [3:0]LEDR;
	
	logic [31:0] clk;
	logic [3:0] out, dffIn, tIn;
	logic tOut1, tOut2;

	//Clock setup
	parameter whichClock = 24;
	clock_divider cdiv (CLOCK_50, clk);
	
	assign LEDR = out;
	assign tIn[0] = ~out[0];
	assign tIn[1] = (out[0]&~out[1])|(~out[0]&out[1]);
	
	assign dffIn[0] = tIn[0];
	assign dffIn[1] = tIn[1];
	assign tOut1 = out[1] & out[0];
	assign dffIn[2] = (tOut1&~out[2])|(~tOut1&out[2]);
	assign tOut2 = out[2] & tOut1;
	assign dffIn[3] = (tOut2&~out[3])|(~tOut2&out[3]);
		
	DFlipFlop dflip0 (.d(dffIn[0]), .q(out[0]), .reset(~KEY[3]), .clk(clk[whichClock]));
	DFlipFlop dflip1 (.d(dffIn[1]), .q(out[1]), .reset(~KEY[3]), .clk(clk[whichClock]));
	DFlipFlop dflip2 (.d(dffIn[2]), .q(out[2]), .reset(~KEY[3]), .clk(clk[whichClock]));
	DFlipFlop dflip3 (.d(dffIn[3]), .q(out[3]), .reset(~KEY[3]), .clk(clk[whichClock]));
	
endmodule

module SynchUpCounter_testbench();

	logic clk; 
	logic [3:0]KEY, LEDR;

	SynchUpCounter dut (.CLOCK_50(clk), .KEY, .LEDR);

// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;	
	end
	
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
									@(posedge clk);
		KEY[3] <= 0; 			@(posedge clk);
		KEY[3] <= 1; 			@(posedge clk);
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