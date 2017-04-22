module JohnsonCounter (CLOCK_50, KEY, LEDR);
	input logic CLOCK_50;
	input logic [3:0]KEY;
	output logic [3:0]LEDR;
	
	logic [31:0] clk;
	logic reset;
	logic [3:0]out;
	
	assign reset = ~KEY[0];
	assign LEDR = out;

	//Clock setup
	parameter whichClock = 0;
	clock_divider cdiv1 (CLOCK_50, clk);
	
	always_ff @ (posedge CLOCK_50)
		if (reset)
			out <= 4'b0000;
		else begin
			if (out == 4'b0000) out <= 4'b1000;
			if (out == 4'b1000) out <= 4'b1100;
			if (out == 4'b1100) out <= 4'b1110;
			if (out == 4'b1110) out <= 4'b1111;
			if (out == 4'b1111) out <= 4'b0111;
			if (out == 4'b0111) out <= 4'b0011;
			if (out == 4'b0011) out <= 4'b0001;
			if (out == 4'b0001) out <= 4'b0000;
		end
	
endmodule

module JohnsonCounter_testbench();

	logic clk; 
	logic [3:0]KEY, LEDR;

	JohnsonCounter dut (.CLOCK_50(clk), .KEY, .LEDR);

// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;	
	end
	
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
									@(posedge clk);
		KEY[0] <= 0; 			@(posedge clk);
		KEY[0] <= 1; 			@(posedge clk);
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
		KEY[0] <= 0; 			@(posedge clk);
		KEY[0] <= 1; 			@(posedge clk);
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