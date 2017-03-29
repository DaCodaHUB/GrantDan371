// Module name: JohnsonCount
//     JohnsonCount.v
//
// Description:
//    A four stage (4 bit) synchronous Johnson
//    counter, with active low reset
//
// Parameters:
//    [in] clk, rst
//
// Returns:
//    [out] [3:0] Q
//
// Author:
//    Grant Maiden, Zhengjie Zhu
// Rev. 0 11 Jan 2017
module JohnsonCount (out, clk, rst);
	input clk, rst;
	output reg [3:0]out;
	reg [2:0] ps, ns;
	
	always@(ps) begin
		case (ps)
			0: begin ns = 1; out = 4'b0000; end
			1: begin ns = 2; out = 4'b0001; end
			2: begin ns = 3; out = 4'b0011; end
			3: begin ns = 4; out = 4'b0111; end
			4: begin ns = 5; out = 4'b1111; end
			5: begin ns = 6; out = 4'b1110; end
			6: begin ns = 7; out = 4'b1100; end
			7: begin ns = 0; out = 4'b1000; end
		endcase
	end
	
	always@(posedge clk) begin
		if (!rst)
			ps <= 0;
		else
			ps <= ns;
	end
endmodule
