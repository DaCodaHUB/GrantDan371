//----------------------------------
//Module: RippleUp
//Designed by: Grant Maiden, Dang Le
//Purpose: DFF for 371 labs
//----------------------------------


module RippleUp (Clk, Reset, out);
	input Clk, Reset;
	output [3:0] out;
	wire [3:0] qBar;
	
	FlipFlop f1 (out[0], qBar[0], qBar[0], Clk, Reset);
	FlipFlop f2 (out[1], qBar[1], qBar[1], qBar[0], Reset);
	FlipFlop f3 (out[2], qBar[2], qBar[2], qBar[1], Reset);
	FlipFlop f4 (out[3], qBar[3], qBar[3], qBar[2], Reset);
endmodule

module RippleUp_testbench();
		reg CLOCK_50, Reset;
		reg [3:0] q;
		RippleUp dut (CLOCK_50, Reset, q);
		
		// Set up the clock.
		parameter CLOCK_PERIOD = 100;
		initial CLOCK_50 = 1;
		always begin
			#(CLOCK_PERIOD/2);
			CLOCK_50 = ~CLOCK_50;
		end

		initial begin
							 @(posedge CLOCK_50);
			Reset <= 0;	 @(posedge CLOCK_50);
			Reset <= 1;	 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
						  	 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
							 @(posedge CLOCK_50);
			$stop;
		end
endmodule

module FlipFlop(q, qBar, D, clk, rst);
	input D, clk, rst;
	output q, qBar;
	reg q;
	not n1 (qBar, q);
	always@ (negedge rst or posedge clk) begin
		if(!rst)
			q = 0;
		else
			q = D;
	end
endmodule
