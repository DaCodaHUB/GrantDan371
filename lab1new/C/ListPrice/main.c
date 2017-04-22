//  preprocessor directive to support printing to the display
#include <stdio.h>

//  the main program
int main(void)
{
	//  declare, define, and initialize some working variables
	float a = 0.0;
    float b = 0.0;
    float c = 0.0;
    float d = 0.0;
    float e = 0.0;

	//  ask the user for some data
	printf("please enter a Dealer Manufacturer Cost\n");
	scanf("%f", &a);

	//  remove newline from input buffer
	getchar();
    
    //  ask the user for some data
	printf("please enter a Dealer Estimated Mark-Up\n");
	scanf("%f", &b);
	//  remove newline from input buffer
	getchar();
    
    //  ask the user for some data
	printf("please enter sales tax percentage (i.e. for 98%% enter \"98\")\n");
	scanf("%f", &c);
	//  remove newline from input buffer
	getchar();
    
    //  ask the user for some data
	printf("please enter estimated pre-tax discount\n");
	scanf("%f", &d);
	//  remove newline from input buffer
	getchar();
    
    e = (a+b-d)*(1+c/100);
    
	//  print the user data to the display
	//    the format will be xx.yy
	printf("Total estimated consumer price is: %2.2f\n", e);

	return 0;
}
