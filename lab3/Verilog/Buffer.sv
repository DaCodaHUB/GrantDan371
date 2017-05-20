module Buffer (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic CLOCK_50;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	
	//reset control
	logic reset;
	assign reset = ~KEY[3];
	
	//METASTABILITY for user inputs
	logic METAflushStart;
	logic clockerino;
	int clockDivider;
	int clockDivider2;
	assign clockDivider = SW[0] + SW[1] + SW[2] + SW[3] + SW[4] + SW[5] + SW[6]; 
	always_comb begin
		if (0 <= clockDivider && clockDivider <= 7)
			clockDivider2 = clockDivider;
		else
			clockDivider2 = 0;
	end
	assign Clockerino = (KEY[1]) ? clk[whichClock]: clk[whichClock - 1 - clockDivider2];
	DFlipFlop BufferStart(KEY[0], METAflushStart, reset, CLOCK_50);
	
	//integer values

	//Clock setup
	parameter whichClock = 21;
	logic [31:0]clk;
	clock_divider cdiv1 (CLOCK_50, clk);
	
	// Mux for clock switching
	//logic clockerino;
	//assign clockerino = (SW[0]) ? clk[whichClock]: clk[whichClock]/1000;
	
	//counter decleration
	integer Buffer1Counter;
	integer Buffer2Counter;
	
	//HEX control for Buffer 1
	integer B1Ones,B1Tens, B1Hundreds;
	assign B1Hundreds = Buffer1Counter/800;
	assign B1Tens = Buffer1Counter/80;
	assign B1Ones = Buffer1Counter%80/8;
	always_comb
		case (B1Hundreds)
			// 	 Light: 6543210
			0: HEX5 = ~7'b0111111; // 0
			1: HEX5 = ~7'b0000110; // 1
			default: HEX5 = 7'b1111111;
		endcase
	always_comb
		case (B1Tens)
			// 	 Light: 6543210
			0: HEX4 = ~7'b0111111; // 0
			1: HEX4 = ~7'b0000110; // 1
			2: HEX4 = ~7'b1011011; // 2
			3: HEX4 = ~7'b1001111; // 3
			4: HEX4 = ~7'b1100110; // 4
			5: HEX4 = ~7'b1101101; // 5
			6: HEX4 = ~7'b1111101; // 6
			7: HEX4 = ~7'b0000111; // 7
			8: HEX4 = ~7'b1111111; // 8
			9: HEX4 = ~7'b1101111; // 9
			10: HEX4 = ~7'b0111111; // 0
			default: HEX4 = 7'b1111111;
		endcase
	always_comb
		case (B1Ones)
			// 	 Light: 6543210
			0: HEX3 = ~7'b0111111; // 0
			1: HEX3 = ~7'b0000110; // 1
			2: HEX3 = ~7'b1011011; // 2
			3: HEX3 = ~7'b1001111; // 3
			4: HEX3 = ~7'b1100110; // 4
			5: HEX3 = ~7'b1101101; // 5
			6: HEX3 = ~7'b1111101; // 6
			7: HEX3 = ~7'b0000111; // 7
			8: HEX3 = ~7'b1111111; // 8
			9: HEX3 = ~7'b1101111; // 9
			10: HEX3 = ~7'b0111111; // 0
			default: HEX3 = 7'b1111111;
		endcase

	//HEX control for buffer 2
	integer B2Ones,B2Tens, B2Hundreds;
	assign B2Hundreds = Buffer2Counter/800;
	assign B2Tens = Buffer2Counter/80;
	assign B2Ones = Buffer2Counter%80/8;
	always_comb
		case (B2Hundreds)
			// 	 Light: 6543210
			0: HEX2 = ~7'b0111111; // 0
			1: HEX2 = ~7'b0000110; // 1
			default: HEX2 = 7'b1111111;
		endcase
	always_comb
		case (B2Tens)
			// 	 Light: 6543210
			0: HEX1 = ~7'b0111111; // 0
			1: HEX1 = ~7'b0000110; // 1
			2: HEX1 = ~7'b1011011; // 2
			3: HEX1 = ~7'b1001111; // 3
			4: HEX1 = ~7'b1100110; // 4
			5: HEX1 = ~7'b1101101; // 5
			6: HEX1 = ~7'b1111101; // 6
			7: HEX1 = ~7'b0000111; // 7
			8: HEX1 = ~7'b1111111; // 8
			9: HEX1 = ~7'b1101111; // 9
			10: HEX1 = ~7'b0111111; // 0
			default: HEX1 = 7'b1111111;
		endcase
	always_comb
		case (B2Ones)
			// 	 Light: 6543210
			0: HEX0 = ~7'b0111111; // 0
			1: HEX0 = ~7'b0000110; // 1
			2: HEX0 = ~7'b1011011; // 2
			3: HEX0 = ~7'b1001111; // 3
			4: HEX0 = ~7'b1100110; // 4
			5: HEX0 = ~7'b1101101; // 5
			6: HEX0 = ~7'b1111101; // 6
			7: HEX0 = ~7'b0000111; // 7
			8: HEX0 = ~7'b1111111; // 8
			9: HEX0 = ~7'b1101111; // 9
			10: HEX0 = ~7'b0111111; // 0
			default: HEX0 = 7'b1111111;
		endcase
	//Additonal Logic State declarations
	bit stateStartFlush1, stateStartFlush2, stateBothCollect, stateBegin, stateBuffer1Collect, stateBuffer2Collect;
	//Flag Declarations
	
	//Additional Counters
		
	always_ff @(posedge Clockerino && KEY[2]) begin
		//reset state
		if (reset) begin //reset to initial conditions
			Buffer1Counter <= 0;
			Buffer2Counter <= 0;
			LEDR <= 10'b10000_10000;
			stateStartFlush1 <= 0;
			stateStartFlush2 <= 0;
			stateBothCollect <= 0;
			stateBegin <= 0;
			stateBuffer1Collect <= 0;
			stateBuffer2Collect <= 0;
		end
		else begin
			//State Select
			if(Buffer1Counter == 0 && Buffer2Counter == 0 && ~stateStartFlush1) begin //begin state
				stateBuffer1Collect <= 1;
				Buffer1Counter <= Buffer1Counter + 2;
				LEDR <= 10'b00100_10000;
			end
			if (Buffer1Counter < 8*80 && ~(Buffer2Counter == 8*100) && ~stateStartFlush1 && stateBuffer1Collect && ~stateBuffer2Collect) begin //buffer 1 increasing buffer 2 0
				Buffer1Counter <= Buffer1Counter + 2;
				
				//--------------------
				if (0 < Buffer2Counter) begin
					Buffer2Counter <= Buffer2Counter - 8;
					LEDR <= 10'b00100_00001;
				end
				else begin
					stateStartFlush2 <= 0;
					LEDR <= 10'b00100_10000;
				end
			end
			if (8*80 <= Buffer1Counter && Buffer1Counter < 8*90 && Buffer2Counter == 0 && ~stateStartFlush1 && stateBuffer1Collect) begin // B1 80-89 B2 0
				Buffer1Counter <= Buffer1Counter + 2;
				LEDR <= 10'b00100_01000;
			end
			if((8*90 <= Buffer1Counter && Buffer1Counter < 8*100) && (Buffer2Counter < 8*80) && ~stateStartFlush1 && stateBuffer1Collect) begin // B1 90-99 B2 < 80 
				Buffer1Counter <= Buffer1Counter + 1;
				Buffer2Counter <= Buffer2Counter + 1;
				if(Buffer1Counter == 799)
					LEDR <= 10'b00010_00100;
				else
					LEDR <= 10'b00100_00100;
			end
			if(Buffer1Counter == 8*100 && Buffer2Counter < 8*80 && ~stateStartFlush1) begin // B1 100 B2 < 100
				Buffer2Counter <= Buffer2Counter + 2;
				stateBuffer1Collect <= 0;
				stateBuffer2Collect <= 1;
				if(~METAflushStart && ~stateStartFlush2)begin
					stateBuffer1Collect <= 0;
					stateBuffer2Collect <= 1;
					LEDR <= 10'b00001_00100;
					stateStartFlush1 <= 1;
					Buffer1Counter <= Buffer1Counter - 8;
				end
				if(Buffer2Counter == 398) begin
					stateBuffer1Collect <= 0;
					stateBuffer2Collect <= 1;
					LEDR <= 10'b00001_00100;
					stateStartFlush1 <= 1;
					Buffer1Counter <= Buffer1Counter - 8;
				end
			end
			if(Buffer1Counter < 8*100 && Buffer2Counter < 8*80 && stateStartFlush1 && stateBuffer2Collect && ~stateBuffer1Collect) begin
				if (0 < Buffer1Counter) begin
					Buffer1Counter <= Buffer1Counter - 8;
					LEDR <= 10'b00001_00100;
				end
				else begin
					stateStartFlush1 <= 0;
					LEDR <= 10'b10000_00100;
				end
				Buffer2Counter <= Buffer2Counter + 2;
			end
			if(Buffer1Counter < 800 && Buffer2Counter < 8*80 && ~stateStartFlush1 && stateBuffer2Collect && ~stateBuffer1Collect) begin
				Buffer2Counter <= Buffer2Counter + 2;
				LEDR <= 10'b10000_00100;
			end
			if(8*80 <= Buffer2Counter && Buffer2Counter < 8*90 && Buffer1Counter == 0 && ~stateStartFlush1 && ~stateStartFlush1 && stateBuffer2Collect && ~stateBuffer1Collect) begin
				Buffer2Counter <= Buffer2Counter + 2;
				LEDR <= 10'b01000_00100;
			end
			if((8*90 <= Buffer2Counter && Buffer2Counter < 8*100) && (Buffer1Counter < 8*80) && ~stateStartFlush1 && stateBuffer2Collect) begin // B1 90-99 B2 < 80 
				Buffer1Counter <= Buffer1Counter + 1;
				Buffer2Counter <= Buffer2Counter + 1;
				if(Buffer2Counter == 799)
					LEDR <= 10'b00100_00010;
				else
					LEDR <= 10'b00100_00100;
			end
			if(Buffer2Counter == 8*100 && Buffer1Counter < 8*80 && ~stateStartFlush2) begin // B1 100 B2 < 100
				Buffer1Counter <= Buffer1Counter + 2;
				stateBuffer1Collect <= 1;
				stateBuffer2Collect <= 0;
				if(~METAflushStart)begin
					stateBuffer1Collect <= 1;
					stateBuffer2Collect <= 0;
					LEDR <= 10'b00100_00001;
					stateStartFlush2 <= 1;
					Buffer2Counter <= Buffer2Counter - 8;
				end
				if(Buffer1Counter == 398) begin
					stateBuffer1Collect <= 1;
					stateBuffer2Collect <= 0;
					LEDR <= 10'b00100_00001;
					stateStartFlush2 <= 1;
					Buffer2Counter <= Buffer2Counter - 8;
				end
			end
		end
	end
endmodule

module Buffer_Testbench();

	logic clk; 
	logic [3:0]KEY;
	logic [9:0]SW, LEDR;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	int i;

	Buffer dut (.CLOCK_50(clk), .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW);

// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;	
	end
	
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
		KEY[3] <= 0;			@(posedge clk);
		KEY[3] <= 0;			@(posedge clk);
		KEY[3] <= 1;			@(posedge clk);
		KEY[0] <= 0; 			@(posedge clk);
		KEY[0] <= 1; 			@(posedge clk);
		for (i=0; i<1200; i++)begin
			@(posedge clk);
		end
		$stop; // End the simulation.
	end
endmodule