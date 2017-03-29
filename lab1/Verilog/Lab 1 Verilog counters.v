module DFlipFlop(q, qBar, D, clk, rst);
	input D, clk, rst;
	output q, qBar;
	reg q;
	not n1 (qBar, q);
	
	always@ (negedge rst or posedge clk)
		begin
			if(!rst)
				q = 0;
			else
				q = D;
		end
endmodule

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

/*module RippleDownCount (clk, out, rst); 'ripple down counter
	input clk, rst;
	output [3:0]out;
	logic [3:0]notOut;
	
	DFlipFlop out0 (.D(notOut[0]), .clk, .rst, .q(out[0]), .qBar(notOut[0]));
	DFlipFlop out1 (.D(notOut[1]), .clk(~out[0]), .rst, .q(out[1]), .qBar(notOut[1]));
	DFlipFlop out2 (.D(notOut[2]), .clk(~out[1]), .rst, .q(out[2]), .qBar(notOut[2]));
	DFlipFlop out3 (.D(notOut[3]), .clk(~out[2]), .rst, .q(out[3]), .qBar(notOut[3]));
	
endmodule

module SyncUpCountSchematic (q, out, clk, rst); 'Synchronous up counter dataflow entry
	input clk, rst;
	output [3:0]out;
	logic [3:0]notOut;
	
	DFlipFlop out0 (.D(1'b1), .clk, .rst, .q(out[0]));
	DFlipFlop out1 (.D(out[0]), .clk, .rst, .q(out[1]));
	DFlipFlop out2 (.D(out[0] && out[1]), .clk, .rst, .q(out[2]));
	DFlipFlop out3 (.D(out[1] && out[2]), .clk, .rst, .q(out[3]));
	
endmodule*/

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

module JohnsonCount (out, clk, rst);
	input clk, rst;
	output reg [3:0]out;
	reg [2:0] ps, ns;
	
	always@(*) begin
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
