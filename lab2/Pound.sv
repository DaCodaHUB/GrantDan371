module Pound (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic CLOCK_50;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	
	//INITIALIAZE Hex displays
	initial begin
	HEX3 = 7'b1111111;
	end
	
	//reset control
	logic reset;
	assign reset = ~KEY[0];
	
	//METASTABILITY for user inputs
	logic METAwaterUp, METAwaterDown, METAarriving, METAdeparting, METAoutsideLock, METAinsideLOCK, METAswitchDirection;
	
	DFlipFlop waterUpFF(KEY[1], METAwaterUp, reset, CLOCK_50);
	DFlipFlop waterDownFF(KEY[2], METAwaterDown, reset, CLOCK_50);
	DFlipFlop arrivingFF(SW[0], METAarriving, reset, CLOCK_50);
	DFlipFlop departingFF(SW[1], METAdeparting, reset, CLOCK_50);
	DFlipFlop outsideLockFF(SW[2], METAoutsideLock, reset, CLOCK_50);
	DFlipFlop insideLockFF(SW[3], METAinsideLock, reset, CLOCK_50);
	DFlipFlop switchDirectionFF(SW[4], METAswitchDirection, reset, CLOCK_50);
	
	//integer values
	integer waterLevelHeight;

	//Clock setup
	parameter whichClock = 20;
	logic [31:0]clk;
	clock_divider cdiv1 (CLOCK_50, clk);
	
	//ledControl
	assign LEDR[9:5] = 4'b0;
	
	//counter control
	integer timeCounter;
	
	//Mux HEX control for feet conversion
	logic [6:0]muxHexSel;
	logic [6:0]waterHEX5, waterHEX4;
	assign HEX5 = waterHEX5;
	assign HEX4 = waterHEX4;
	
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
			0: waterHEX5 = ~7'b0111111; // 0
			1: waterHEX5 = ~7'b0000110; // 1
			2: waterHEX5 = ~7'b1011011; // 2
			3: waterHEX5 = ~7'b1001111; // 3
			4: waterHEX5 = ~7'b1100110; // 4
			5: waterHEX5 = ~7'b1101101; // 5
			default: waterHEX5 = 7'b1111111;
		endcase
	always_comb
		case (feetDecimal)
			// 	 Light: 6543210
			0: waterHEX4 = ~7'b0111111; // 0
			1: waterHEX4 = ~7'b0000110; // 1
			2: waterHEX4 = ~7'b1011011; // 2
			3: waterHEX4 = ~7'b1001111; // 3
			4: waterHEX4 = ~7'b1100110; // 4
			5: waterHEX4 = ~7'b1101101; // 5
			6: waterHEX4 = ~7'b1111101; // 6
			7: waterHEX4 = ~7'b0000111; // 7
			8: waterHEX4 = ~7'b1111111; // 8
			9: waterHEX4 = ~7'b1101111; // 9
			default: waterHEX4 = 7'b1111111;
		endcase
	
	//Additonal Logic State declarations
	integer waterControlEnable, waterLevelHigh, waterLevelLow, arrivingState, arrivingState2, arrivingDirectionState, boatDockedState;
	//Flag Declarations
	integer arrivingFlag, arrivingFlag2, LEDflashEnable;
	//Additional Counters
	integer ledFlashCounter;
		
	always_ff @(posedge CLOCK_50) begin
		//reset state
		if (reset) begin //reset to low water state
			waterLevelHeight <= 0;
			timeCounter <= 0;
			LEDR[0] <= 0;
			LEDR[1] <= 0;
			LEDR[2] <= 1;
			LEDR[3] <= 1;
			LEDR[4] <= 0;
			waterControlEnable <= 1;
			arrivingState <= 0;
			arrivingState2 <= 0;
			arrivingFlag <= 0;
			arrivingFlag2 <= 0;
			arrivingDirectionState <= 0;
			boatDockedState <= 0;
			LEDflashEnable <= 0;
		end
		
		//Direction of Boat Control Begin
		if (~METAswitchDirection && arrivingFlag == 0 && arrivingFlag2 == 0 )begin
			LEDR[4] <= 0;
			arrivingDirectionState <= 0;
		end
		else if (METAswitchDirection && arrivingFlag == 0 &&  arrivingFlag2 == 0) begin
			LEDR[4] <= 1;
			arrivingDirectionState <= 1;
		end
		//Direction of Boat Control Begin
		
		//waterControl STATE block
		if(waterControlEnable == 1) begin
			if(METAoutsideLock && 0 <= waterLevelHeight && waterLevelHeight <= 4536) begin //if inbetween 0.0 and 0.3
				waterLevelLow <= 1;
				waterControlEnable <= 0;
				waterLevelHeight <= 0;
				//LEDR[2] <= 1'b0;
			end
			if(METAinsideLock && 52640 <= waterLevelHeight && waterLevelHeight <= 56000) begin //if inbetween 4.7 and 5.0
				waterLevelHigh <= 1;
				waterControlEnable <= 0;
				waterLevelHeight <= 56000;
				//LEDR[3] <= 1'b0;
			end
			else if(waterLevelHeight > 56000)
				waterLevelHeight <= 56000;
			else if (waterLevelHeight < 0)
				waterLevelHeight <= 0;
			else if(~METAwaterUp && METAwaterDown) begin
				waterLevelHeight <= waterLevelHeight + 112;	
			end
			else if(METAwaterUp && ~METAwaterDown) begin
				waterLevelHeight <= waterLevelHeight - 127;	
			end	
		end
		//waterControl STATE block END
		
		//Turn on Arriving State, Start 5min timer
		if (~METAswitchDirection && METAarriving && arrivingFlag == 0 && arrivingFlag2 == 0) begin
			LEDR[0] <= 1'b1;
			timeCounter <= 300;
			arrivingFlag <= 1;
			ledFlashCounter <= 0;
			LEDflashEnable <= 1;
		end
		else if (METAswitchDirection && METAarriving && arrivingFlag2 == 0 && arrivingFlag == 0) begin
			LEDR[0] <= 1'b1;
			timeCounter <= 300;
			arrivingFlag2 <= 1;
			ledFlashCounter <= 0;
			LEDflashEnable<= 1;
		end
		//WaterLevelHighState Begin
		if(waterLevelHigh == 1)begin
			if (arrivingFlag == 1) begin //boat has arrived, ready to depart, going HIGH TO LOW
				if(arrivingFlag == 1 && timeCounter == 0 && LEDflashEnable == 1) begin 
					boatDockedState <= 1;
					ledFlashCounter <= ledFlashCounter + 1;
					if (((ledFlashCounter/16) %2) == 0)
						LEDR[0] <= 1'b0;
					else 
						LEDR[0] <= 1'b1;
				end
				if (METAdeparting && arrivingFlag == 1 && boatDockedState == 1) begin
					LEDR[0] <= 1'b0;
					LEDR[1] <= 1'b1;
				end
				if (METAinsideLock)
					LEDR[3] <= 1'b0;
				else if (~METAinsideLock) begin
					LEDR[3] <= 1'b1;
					//LEDR[0] <= 1'b0;
					waterLevelHigh <= 0;
					waterControlEnable <= 1;
				end
			end
			else if (arrivingFlag2 == 1) begin //BOAT LEAVING (LOW TO HIGH)
				if(arrivingFlag2 == 1 && boatDockedState) begin
					LEDR[1] <= 1'b0;
					boatDockedState <= 0;
					arrivingFlag2 <= 0;
				end
				if(METAinsideLock)
					LEDR[3] <= 1'b0;
				else if (~METAinsideLock) begin
					LEDR[3] <= 1'b1;
					waterLevelHigh <= 0;
					waterControlEnable <= 1;
				end
			end
			else begin //NO BOAT DEPARTING
				if (METAinsideLock)
					LEDR[3] <= 1'b0;
				else if (~METAinsideLock) begin
					LEDR[3] <= 1'b1;
					waterLevelHigh <= 0;
					waterControlEnable <= 1;
				end
			end
		end
		//WaterLevelHighState END
		
		//WaterLevel LOW state Begin
		if(waterLevelLow == 1) begin
			if (arrivingFlag == 1 && boatDockedState) begin //Boat is departing (HIGH TO LOW)
				if(arrivingFlag == 1) begin
					LEDR[1] <= 1'b0;
					boatDockedState <= 0;
					arrivingFlag <= 0;
				end
				if(METAoutsideLock)
					LEDR[2] <= 1'b0;
				else if (~METAoutsideLock) begin
					LEDR[2] <= 1'b1;
					waterLevelLow <= 0;
					waterControlEnable <= 1;
				end
			end
			else if (arrivingFlag2 == 1) begin //Boat is arriving (LOW to HIGH)
				if(arrivingFlag2 == 1 && timeCounter == 0 && LEDflashEnable == 1) begin 
					boatDockedState <= 1;
					ledFlashCounter <= ledFlashCounter + 1;
					if (((ledFlashCounter/16) %2) == 0)
						LEDR[0] <= 1'b0;
					else 
						LEDR[0] <= 1'b1;
				end
				if (METAdeparting && arrivingFlag2 == 1 && boatDockedState == 1) begin
					LEDR[0] <= 1'b0;
					LEDR[1] <= 1'b1;
				end
				if (METAoutsideLock)
					LEDR[2] <= 1'b0;
				else if (~METAoutsideLock) begin
					LEDR[2] <= 1'b1;
					//LEDR[0] <= 1'b0;
					waterLevelLow <= 0;
					waterControlEnable <= 1;
				end
			end
			else begin //No boat arriving
				if(METAoutsideLock)
					LEDR[2] <= 1'b0;
				else if (~METAoutsideLock) begin
					LEDR[2] <= 1'b1;
					waterLevelLow <= 0;
					waterControlEnable <= 1;
				end
			end
		end
		//WaterLevel LOW State END
		
		//CounterControl BEGIN
		if(timeCounter > 0 && ~reset) begin
			timeCounter <= timeCounter - 1;
		end
		//CounterCOntrol END
		
		//Stop Flashing dock lights
		if (METAdeparting && boatDockedState == 1) begin
					LEDR[0] <= 1'b0;
					LEDflashEnable <= 0;
		end
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
		KEY[0] <= 0; 			@(posedge clk);@(posedge clk);@(posedge clk);
		KEY[0] <= 1; 			@(posedge clk);@(posedge clk);@(posedge clk);
		KEY[1] <= 1;	SW[0] <= 0;	SW[4] <= 0;	@(posedge clk);@(posedge clk);@(posedge clk);
		SW <= 10'b0;
		SW[1]	<= 0;				@(posedge clk);@(posedge clk);@(posedge clk);
		KEY[2] <= 1;			@(posedge clk);@(posedge clk);@(posedge clk);
									@(posedge clk);@(posedge clk);@(posedge clk);
		SW[0] <= 1;				@(posedge clk);@(posedge clk);@(posedge clk);
		KEY[1] <= 0;			@(posedge clk);@(posedge clk);@(posedge clk);
									@(posedge clk);@(posedge clk);@(posedge clk);
		SW[0]	<= 0;				@(posedge clk);@(posedge clk);@(posedge clk);
									@(posedge clk);@(posedge clk);@(posedge clk);
		SW[3] <= 1;	@(posedge clk);@(posedge clk);@(posedge clk);
		for(i = 0; i <480; i++) begin
			@(posedge clk);
			if (i == 300)
				SW[3] <= 0;
				SW[1]	<= 0;	
		end
		KEY[1] <= 1;						@(posedge clk);
		SW[3] <= 1;				@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
		SW[3] <= 0;				@(posedge clk);
		SW[1]	<= 1;				@(posedge clk);
									@(posedge clk);
		KEY[2] <= 0;			@(posedge clk);
									@(posedge clk);
		for(i = 0; i <475; i++) begin
			@(posedge clk);
		end
									@(posedge clk);
									
		SW[2]	<= 1;				@(posedge clk);
									@(posedge clk);
									@(posedge clk);
		SW <= 10'b0000010001;			@(posedge clk);
		for(i = 0; i <300; i++) begin
			@(posedge clk);
		end
		SW<= 10'b0000010100; @(posedge clk);
		for(i = 0; i <33; i++) begin
			@(posedge clk);
		end
		SW <= 10'b0000010111;			@(posedge clk);
									@(posedge clk);
									@(posedge clk);
		SW <= 10'b0000010011;			@(posedge clk);
		KEY[1] <= 0; KEY[2] <= 1;
		for(i = 0; i <510; i++) begin
			@(posedge clk);
		end
		SW <= 10'b0000011011;			@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);@(posedge clk);
		$stop; // End the simulation.
	end
endmodule