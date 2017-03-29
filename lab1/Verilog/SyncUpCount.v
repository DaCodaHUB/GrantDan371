// SynchUpCount
//
// Purpose:
//    Up counter that begins at 0000 on reset, and overflows from 1111 to 0000. Increments on Posedge clock
//
// Parameters:
//    [in] clk, reset
//
// Returns:
//    [out]Q
//
// Module:
//    Synchronous Up counter
//
// Author:
//    Zhengjie, Zhu
// Rev. 1 15 January 2017
//-----------------------------------------------------------

module SyncUpCount(clk, rst, Q);
	input clk, rst;
	wire q0, q1, q2, q3, q0Bar, q1Bar, q2Bar, q3Bar;
	wire d1, d2, d3;
	output [3:0] Q;
	
	assign d1 = q0 ~^ q1Bar;
	assign d2 = (q0 & q1) ~^ q2Bar;
	assign d3 = (q0 & q1 & q2) ~^ q3Bar;
	
	DFlipFlop D0(q0, q0Bar, q0Bar, clk, rst);
	DFlipFlop D1(q1, q1Bar, d1, 	 clk, rst);
	DFlipFlop D2(q2, q2Bar, d2, 	 clk, rst);
	DFlipFlop D3(q3, q3Bar, d3, 	 clk, rst);
	
	assign Q = {q3, q2, q1, q0};
	
endmodule

module DFlipFlop(q, qBar, D, clk, rst);
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
