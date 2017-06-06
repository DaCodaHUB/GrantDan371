module mux5bit_e1 (in, x_out, y_out);
	input logic [5:0] in;
	output int x_out, y_out;
	int x_shift;
	int y_shift;
	int e2_y;
	assign x_shift = 60;
	assign y_shift = 140;
	assign e2_y = 0;
	
	
	always_comb begin
		if(in == 0)
			begin
				x_out = 545;
				y_out = 325;
			end
		else if(in == 1)
			begin
				x_out = 545 - 1 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 2)
			begin
				x_out = 545 - 2 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 3)
			begin
				x_out = 545 - 3 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 4)
			begin
				x_out = 545 - 4 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 5)
			begin
				x_out = 545 - 5 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 6)
			begin
				x_out = 545 - 6 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 7)
			begin
				x_out = 545 - 7 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 8)
			begin
				x_out = 545 - 8 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 9)
			begin
				x_out = 545 - 8 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 10)
			begin
				x_out = 545 - 7 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 11)
			begin
				x_out = 545 - 6 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 12)
			begin
				x_out = 545 - 5 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 13)
			begin
				x_out = 545 - 4 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 14)
			begin
				x_out = 545 - 3 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 15)
			begin
				x_out = 545 - 2 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 16)
			begin
				x_out = 545 - 1 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 17)
			begin
				x_out = 545 - 0 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 18)
			begin
				x_out = 545 - 0 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 19)
			begin
				x_out = 545 - 1 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 20)
			begin
				x_out = 545 - 2 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 21)
			begin
				x_out = 545 - 3 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 22)
			begin
				x_out = 545 - 4 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 23)
			begin
				x_out = 545 - 5 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 24)
			begin
				x_out = 545 - 6 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 25)
			begin
				x_out = 545 - 7 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 26)
			begin
				x_out = 545 - 8 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 27)
			begin
				x_out = 550 - 8 * x_shift;
				y_out = 362 - 2 * y_shift;
			end
		else if(in == 28)
			begin
				x_out = 20;
				y_out = 362 - 2 * y_shift;
			end
		else if(in == 29)
			begin
				x_out = 20;
				y_out = 425;
			end
		else if(in == 30)
			begin
				x_out = 550;
				y_out = 425;
			end
		else if(in == 31)
			begin
				x_out = 550 - 8 * x_shift;
				y_out = 5;
			end
		else
			begin
				x_out = 15;
				y_out = 20;
			end
	end
endmodule
		
module mux5bit_e2 (in, x_out, y_out);
	input logic [5:0] in;
	output int x_out, y_out;
	int x_shift;
	int y_shift;
	int e2_y;
	assign x_shift = 60;
	assign y_shift = 140;
	assign e2_y = -75;
	
	always_comb begin
		if(in == 5'b00000)
			begin
				x_out = 545;
				y_out = 400;
			end
		else if(in == 1)
			begin
				x_out = 545 - 1 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 2)
			begin
				x_out = 545 - 2 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 3)
			begin
				x_out = 545 - 3 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 4)
			begin
				x_out = 545 - 4 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 5)
			begin
				x_out = 545 - 5 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 6)
			begin
				x_out = 545 - 6 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 7)
			begin
				x_out = 545 - 7 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 8)
			begin
				x_out = 545 - 8 * x_shift;
				y_out = 325 - 0 * y_shift - e2_y;
			end
		else if(in == 9)
			begin
				x_out = 545 - 8 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 10)
			begin
				x_out = 545 - 7 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 11)
			begin
				x_out = 545 - 6 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 12)
			begin
				x_out = 545 - 5 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 13)
			begin
				x_out = 545 - 4 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 14)
			begin
				x_out = 545 - 3 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 15)
			begin
				x_out = 545 - 2 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 16)
			begin
				x_out = 545 - 1 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 17)
			begin
				x_out = 545 - 0 * x_shift;
				y_out = 325 - 1 * y_shift - e2_y;
			end
		else if(in == 18)
			begin
				x_out = 545 - 0 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 19)
			begin
				x_out = 545 - 1 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 20)
			begin
				x_out = 545 - 2 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 21)
			begin
				x_out = 545 - 3 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 22)
			begin
				x_out = 545 - 4 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 23)
			begin
				x_out = 545 - 5 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 24)
			begin
				x_out = 545 - 6 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 25)
			begin
				x_out = 545 - 7 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 26)
			begin
				x_out = 545 - 8 * x_shift;
				y_out = 325 - 2 * y_shift - e2_y;
			end
		else if(in == 27)
			begin
				x_out = 550 - 8 * x_shift;
				y_out = 362 - 2 * y_shift;
			end
		else if(in == 28)
			begin
				x_out = 20;
				y_out = 362 - 2 * y_shift;
			end
		else if(in == 29)
			begin
				x_out = 20;
				y_out = 425;
			end
		else if(in == 30)
			begin
				x_out = 550;
				y_out = 425;
			end
		else if(in == 31)
			begin
				x_out = 550 - 8 * x_shift;
				y_out = 5;
			end
		else
			begin
				x_out = 15;
				y_out = 20;
			end
	end
endmodule