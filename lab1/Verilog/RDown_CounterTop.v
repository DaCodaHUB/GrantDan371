`include "RDown_Counter.v"

module testBench;

	wire		clk, rst;
	wire [3:0]	Q;

	RDown_Counter counter(clk, rst, Q);
	
	Tester  test(clk, rst, Q);

	initial
	begin
		$dumpfile("RDown_Counter.vcd");
		$dumpvars(1, counter);
	end
endmodule

module Tester(clk, rst, Q);
	
	input [3:0]	Q;
	output reg	clk, rst;
	parameter clk_T = 1;

	initial
	begin
		$display("\t\t clk rst \t Q \t	Time");
		$monitor("\t\t %b \t %b \t %b", clk, rst, Q, $time);
	end

	initial
	begin
		clk = 1'b0;
		forever #clk_T clk = ~clk;
	end
	
	initial begin
		#0	 rst = 1'b0;
		#1	 rst = 1'b1;
		
		#(40*clk_T);
		#1 rst = 1'b0;
		#1 rst = 1'b1;
		
		#(40*clk_T);
		$finish;
	end
endmodule
