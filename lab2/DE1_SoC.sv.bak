//----------------------------------
//Module: D Flip Flop
//Designed by: Grant Maiden, Dang Le
//Purpose: DFF for 371 labs
//----------------------------------


module dff (
d, //d input
q, //q output
clk); //clock

	input d, f, clk;
	
	always_ff @(posedge clk)
		if (reset)
			d <= 0;
		else
			q<= d;
	end
endmodule
