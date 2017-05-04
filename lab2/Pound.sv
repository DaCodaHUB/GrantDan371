module Pound (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic CLOCK_50;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	//boolean flag values
	integer resetFlag, stateLevelHigh, stateLevelLow, stateIncreasingWater, stateDecreasingWater, stateArriving, stateDeparting;
	
	//INITIALIAZE Hex displays
	initial begin
	HEX3 = 7'b1111111;
	end
	
	//METASTABILITY for user inputs
	logic METAwaterUp, METAwaterDown, METAarriving, METAdeparting, METAoutsideLock, METAinsideLOCK, METAswitchDirection;
	DFlipFlop waterUpFF(KEY[1], METAwaterUp, reset, CLOCK_50);
	DFlipFlop waterDownFF(KEY[2], METAwaterDown, reset, CLOCK_50);
	DFlipFlop arrivingFF(SW[0], METAarriving, reset, CLOCK_50);
	DFlipFlop departingFF(SW[1], METAdeparting, reset, CLOCK_50);
	DFlipFlop outsideLockFF(SW[2], METAoutsideLock, reset, CLOCK_50);
	DFlipFlop insideLockFF(SW[3], METAinsideLOCK, reset, CLOCK_50);
	DFlipFlop switchDirectionFF(SW[4], METAswitchDirection, reset, CLOCK_50);
		
	//reset control
	logic reset;
	
	//integer values
	integer waterLevelHeight;
	integer boatInLock;
	
	//reset declaration
	assign reset = ~KEY[0];

	//Clock setup
	parameter whichClock = 0;
	logic [31:0]clk;
	clock_divider cdiv1 (CLOCK_50, clk);
	
	//ledControl
	logic [3:0]ledState;
	assign LEDR[3:0] = ledState[3:0];
	assign LEDR[9:4] = 6'b0;
	
	//counter control
	integer timeCounter, timerOnFlag;
	
	//Mux HEX control for feet conversion
	logic [6:0]muxHexSel;
	logic [6:0]increasingHEX5, increasingHEX4;
	logic [6:0]decreasingHEX5, decreasingHEX4;
	mux2_1 hex4Converter(.out(HEX4), .i0(increasingHEX4), .i1(decreasingHEX4), .sel(muxHexSel));
	mux2_1 hex5Converter(.out(HEX5), .i0(increasingHEX5), .i1(decreasingHEX5), .sel(muxHexSel));
	
	//HEX control for Arrival timer
	integer minutes,tens,ones;
	assign minutes = timeCounter/60;
	assign tens = (timeCounter % 60)/10;
	assign ones = (timeCounter % 60) % 10;
	always_comb
		case (minutes)
			// 	 Light: 6543210
			0: HEX2 = ~7'b0111111; // 0
			1: HEX2 = ~7'b0000110; // 1
			2: HEX2 = ~7'b1011011; // 2
			3: HEX2 = ~7'b1001111; // 3
			4: HEX2 = ~7'b1100110; // 4
			5: HEX2 = ~7'b1101101; // 5
			default: HEX2 = 7'b1111111;
		endcase
	always_comb
		case (tens)
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
			default: HEX1 = 7'b1111111;
		endcase
	always_comb
		case (ones)
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
			default: HEX0 = 7'b1111111;
		endcase
	
	//HEX control for waterLevel while increasing
	integer feetOnes, feetDecimal;

	assign feetOnes = waterLevelHeight / 11200;
	assign feetDecimal = ((waterLevelHeight/1120) % 10);
	
	always_comb
		case (feetOnes)
			// 	 Light: 6543210
			0: increasingHEX5 = ~7'b0111111; // 0
			1: increasingHEX5 = ~7'b0000110; // 1
			2: increasingHEX5 = ~7'b1011011; // 2
			3: increasingHEX5 = ~7'b1001111; // 3
			4: increasingHEX5 = ~7'b1100110; // 4
			5: increasingHEX5 = ~7'b1101101; // 5
			default: increasingHEX5 = 7'b1111111;
		endcase
	always_comb
		case (feetDecimal)
			// 	 Light: 6543210
			0: increasingHEX4 = ~7'b0111111; // 0
			1: increasingHEX4 = ~7'b0000110; // 1
			2: increasingHEX4 = ~7'b1011011; // 2
			3: increasingHEX4 = ~7'b1001111; // 3
			4: increasingHEX4 = ~7'b1100110; // 4
			5: increasingHEX4 = ~7'b1101101; // 5
			6: increasingHEX4 = ~7'b1111101; // 6
			7: increasingHEX4 = ~7'b0000111; // 7
			8: increasingHEX4 = ~7'b1111111; // 8
			9: increasingHEX4 = ~7'b1101111; // 9
			default: increasingHEX4 = 7'b1111111;
		endcase
	
	//HEX control for waterlevel while decreasing
	integer feetOnesDec, feetDecimalDec;
	assign feetOnesDec = 1191 * waterLevelHeight / 100000;
	assign feetDecimalDec = ((1191 * waterLevelHeight) % 100000)/10000;
	
	always_comb
		case (feetOnesDec)
			// 	 Light: 6543210
			0: decreasingHEX5 = ~7'b0111111; // 0
			1: decreasingHEX5 = ~7'b0000110; // 1
			2: decreasingHEX5 = ~7'b1011011; // 2
			3: decreasingHEX5 = ~7'b1001111; // 3
			4: decreasingHEX5 = ~7'b1100110; // 4
			5: decreasingHEX5 = ~7'b1101101; // 5
			default: decreasingHEX5 = 7'b1111111;
		endcase
	always_comb
		case (feetDecimalDec)
			// 	 Light: 6543210
			0: decreasingHEX4 = ~7'b0111111; // 0
			1: decreasingHEX4 = ~7'b0000110; // 1
			2: decreasingHEX4 = ~7'b1011011; // 2
			3: decreasingHEX4 = ~7'b1001111; // 3
			4: decreasingHEX4 = ~7'b1100110; // 4
			5: decreasingHEX4 = ~7'b1101101; // 5
			6: decreasingHEX4 = ~7'b1111101; // 6
			7: decreasingHEX4 = ~7'b0000111; // 7
			8: decreasingHEX4 = ~7'b1111111; // 8
			9: decreasingHEX4 = ~7'b1101111; // 9
			default: decreasingHEX4 = 7'b1111111;
		endcase

	
	always_ff @(posedge CLOCK_50) begin
		//reset state
		if (reset) begin //reset to low water state
			waterLevelHeight <= 0;
			stateLevelLow <= 1;
			stateArriving <= 0;
			stateLevelHigh <= 0; 
			stateIncreasingWater<=0;
			stateDecreasingWater<=0;
			stateDeparting <= 0;
			ledState <= 4'b1000;
			timeCounter <= 0;
			timerOnFlag <= 0;
			boatInLock <= 0;
		end
		if(stateLevelLow == 1) begin //ledControl
			ledState <= 4'b1000;
		end
		if(stateLevelLow == 1 && METAarriving) begin //turn on stateIncreasingWater and stateArriving
			ledState <= 4'b1101;
			stateLevelLow <= 0;
			stateIncreasingWater <= 1;
			stateArriving <= 1;
			timerOnFlag <= 1;
			timeCounter <= 300;
			muxHexSel <= 7'b0000000;
		end
		if(~METAinsideLOCK && ~METAoutsideLock) begin //waterlevelcontrol ON until 4.7 height or 0.3 height
			if (waterLevelHeight > 56000)
				waterLevelHeight <= 56000;
			else if (~METAwaterUp && ~METAwaterDown)
				waterLevelHeight <= waterLevelHeight;
			else begin
				if (~METAwaterUp)begin
					waterLevelHeight <= waterLevelHeight + 112;
				end
				if (~METAwaterDown && waterLevelHeight == 0)begin
					waterLevelHeight <= 0;
				end	
				if (~METAwaterDown && waterLevelHeight != 0)begin
					waterLevelHeight <= waterLevelHeight - 127;
				end					
			end
		end
		if(stateArriving == 1) begin
			if (stateIncreasingWater == 1)
				ledState <= 4'b1101;
			else
				ledState <= 4'b0101;
		end
		if (timerOnFlag == 1) begin
			if(timeCounter == 0) begin
				timeCounter <= 0;
				stateArriving <= 1;
			end
			else
				timeCounter <= timeCounter - 1;		
		end
		//WATER HIGH && ARRIVING BOAT
		if(450 < waterLevelHeight && waterLevelHeight <481 && METAinsideLOCK && stateArriving) begin
			ledState <= 4'b0101;
			waterLevelHeight <= 480;
			//open or close lock
		end
		if(450 < waterLevelHeight && waterLevelHeight < 481 && ~METAinsideLOCK && stateArriving) begin
			ledState <= 4'b1101;
			boatInLock <= 1;
			//open or close lock
		end
		if (boatInLock == 1) begin
			if(METAdeparting && ~METAinsideLOCK) begin //DECREASINGWATER state and stateDeparting
				stateDecreasingWater <= 1;
				stateDeparting <= 1;
				stateIncreasingWater <= 0;
				stateArriving <= 0;
				ledState <= 4'b1110;
				waterLevelHeight <= 420;
				muxHexSel <= 7'b1111111;
			end
		end
		if(stateDecreasingWater == 1) begin //waterlevelcontrol ON until 4.7 height
			if (waterLevelHeight == 421)
				waterLevelHeight <= 420;
			else if (~METAwaterUp && ~METAwaterDown)
				waterLevelHeight <= waterLevelHeight;
			else begin
				if (~METAwaterUp)begin
					waterLevelHeight <= waterLevelHeight + 1;
				end
				if (~METAwaterDown && waterLevelHeight == 0)begin
					waterLevelHeight <= 0;
				end	
				if (~METAwaterDown && waterLevelHeight != 0)begin
					waterLevelHeight <= waterLevelHeight - 1;
				end
			end
		end
		if(0 < waterLevelHeight && waterLevelHeight <26 && METAoutsideLock && stateDeparting) begin
			ledState <= 4'b1000;
			waterLevelHeight <= 480;
			stateDecreasingWater <= 0;
			stateDeparting <= 0;
			boatInLock <= 0;
			//open or close lock
		end
		if(0 < waterLevelHeight && waterLevelHeight < 26 && ~METAoutsideLock && stateDeparting) begin
			ledState <= 4'b1100;
			//open or close lock
		end
		//if (METAarriving && waterLevelHigh == 1)
		//if (METAarriving && waterLevelLow == 1)
		end
endmodule

module Pound_Testbench();

	logic clk; 
	logic [3:0]KEY;
	logic [9:0]SW, LEDR;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	int i;

	Pound dut (.CLOCK_50(clk), .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW);

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
		KEY[1] <= 1;			@(posedge clk);
		SW[1]	<= 1;							@(posedge clk);
		KEY[2] <= 1;							@(posedge clk);
									@(posedge clk);
		SW[0] <= 1;				@(posedge clk);
		KEY[1] <= 0;			@(posedge clk);
									@(posedge clk);
		SW[0]	<= 0;				@(posedge clk);
					@(posedge clk);
		SW[3] <= 1;
		for(i = 0; i <480; i++) begin
			@(posedge clk);
			if (i == 300)
				SW[3] <= 0;
				SW[1]	<= 0;	
		end
		KEY[1] <= 1;						@(posedge clk);
		SW[3] <= 1;				@(posedge clk);
									@(posedge clk);
		SW[3] <= 0;				@(posedge clk);
		SW[1]	<= 1;				@(posedge clk);
									@(posedge clk);
		KEY[2] <= 0;			@(posedge clk);
									@(posedge clk);
		for(i = 0; i <480; i++) begin
			@(posedge clk);
		end
									@(posedge clk);
									
		$stop; // End the simulation.
	end
endmodule