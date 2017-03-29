// UpCounter
//
// Purpose:
//    Up counter that begins at 0000 on reset, and overflows from 1111 to 0000. Increments on Posedge clock
//
// Parameters:
//    [in] clk, reset
//
// Returns:
//    [out]Out
//
// Module:
//    Synchronous Up counter
//
// Author:
//    Zhengjie, Zhu
// Rev. 1 15 January 2017
//-----------------------------------------------------------

module UpCounter(
	Clock,
	Reset,
	Out
);


input wire	Clock;
input wire	Reset;
output wire	[3:0] Out;

wire	Clock_Node;
reg	[3:0] Q;
wire	reset_node;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_6;





always@(posedge Clock_Node or negedge reset_node)
begin
if (!reset_node)
	begin
	Q[0] <= 0;
	end
else
	begin
	Q[0] <= SYNTHESIZED_WIRE_0;
	end
end


always@(posedge Clock_Node or negedge reset_node)
begin
if (!reset_node)
	begin
	Q[1] <= 0;
	end
else
	begin
	Q[1] <= SYNTHESIZED_WIRE_1;
	end
end


always@(posedge Clock_Node or negedge reset_node)
begin
if (!reset_node)
	begin
	Q[2] <= 0;
	end
else
	begin
	Q[2] <= SYNTHESIZED_WIRE_2;
	end
end


always@(posedge Clock_Node or negedge reset_node)
begin
if (!reset_node)
	begin
	Q[3] <= 0;
	end
else
	begin
	Q[3] <= SYNTHESIZED_WIRE_3;
	end
end

assign	SYNTHESIZED_WIRE_7 = Q[0] & Q[1];

assign	SYNTHESIZED_WIRE_6 = SYNTHESIZED_WIRE_7 & Q[2];

assign	SYNTHESIZED_WIRE_0 =  ~Q[0];

assign	SYNTHESIZED_WIRE_1 = Q[0] ^ Q[1];

assign	SYNTHESIZED_WIRE_2 = SYNTHESIZED_WIRE_7 ^ Q[2];

assign	SYNTHESIZED_WIRE_3 = SYNTHESIZED_WIRE_6 ^ Q[3];

assign	Out = Q;
assign	reset_node = Reset;
assign	Clock_Node = Clock;

endmodule
