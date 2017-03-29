// RDown_Counter
//
// Purpose:
//    Down counter that begins at 0000 on reset, and underflows, then continues counting down.
//
// Parameters:
//    [in] clk, reset
//
// Returns:
//    [out]Q
//
// Module:
//    Ripple Down Counter
//
// Author:
//    Zhengjie, Zhu
// Rev. 1 15 January 2017
//-----------------------------------------------------------

module RDown_Counter(clk, rst, Q);
	input clk, rst;
	wire q0, q1, q2, q3, q0Bar, q1Bar, q2Bar, q3Bar;
	output [3:0] Q;
	DFlipFlop D0(q0, q0Bar, q0Bar, clk, rst);
	DFlipFlop D1(q1, q1Bar, q1Bar, q0Bar,  rst);
	DFlipFlop D2(q2, q2Bar, q2Bar, q1Bar,  rst);
	DFlipFlop D3(q3, q3Bar, q3Bar, q2Bar,  rst);
	
	assign Q = {q3Bar, q2Bar, q1Bar, q0Bar};
	
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
