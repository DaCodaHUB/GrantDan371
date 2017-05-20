//----------------------------------
//Module: D Flip Flop
//Designed by: Grant Maiden, Dang Le
//Purpose: DFF for 371 labs
//----------------------------------


module DFlipFlop (
d, //d input
q, //q output
reset, //reset input
clk); //clock

	input logic d, reset, clk;
	output logic q;
	
	always_ff @(posedge clk)
		if (reset)
			q <= 0;
		else
			q <= d;
	
endmodule

module DFF_testbench();

	logic d, q, reset, clk; 

	DFlipFlop dflip(d, q, reset, clk);

// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;	
	end
	
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
									@(posedge clk);
		reset <= 1; 			@(posedge clk);
		reset <= 0; 			@(posedge clk);
									@(posedge clk);
		d <= 0;					@(posedge clk);
									@(posedge clk);
									@(posedge clk);
		d <= 1;					@(posedge clk);
		
		$stop; // End the simulation.
	end

endmodule

