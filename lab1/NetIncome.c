// Net Income Calculator Module
// EE 469, Lab 1
// 
// This program prompts the user for financial data, eventually
// determining net income after taxes and Social Security payments
// This program then prints to the console the net income value
// 
// Authors: Andrique Liu, Grant Maiden, Zhengjie Zhu

#include <stdio.h> // Standard I/O

#define SSMAX 65000.0       // Social Security max threshold
#define SSPCTG 10.3         // Social Security payment percentage
#define FEDTAXMINPAY 3500.0 // Federal tax minimum payment
#define FEDTAXMIN 30000.0   // Federal tax min threshold
#define FEDTAXPCTG 28.0     // Federal tax payment percentage

// Struct to hold financial values
typedef struct 
{
   double startingSalary; // Starting salary
   double stateTax;       // State tax; percentage of gross
   double statePayment;   // State tax payment
   double SSPayment;      // Social Security payment
   double fedPayment;     // Federal tax payment
   double netIncome;      // Net income
} dataValues;

// Forward declarations
void welcome(dataValues *data);
void stateTaxCalculator(dataValues *data);
void SSTaxCalculator(dataValues *data);
void fedTaxCalculator(dataValues *data);
void netIncomeCalculator(dataValues *data);
void debug(dataValues *data);

int main()
{
   dataValues data;
   dataValues *dataptr = &data;
   
   welcome(dataptr);
   stateTaxCalculator(dataptr);
   SSTaxCalculator(dataptr);
   fedTaxCalculator(dataptr);
   netIncomeCalculator(dataptr);
   // debug(dataptr);
   printf("Net income: %.2lf\n", data.netIncome);

   return 0;
}

// welcome prompts the user for starting salary
void welcome(dataValues *data)
{
   printf("Net Income Calculator\n");
   printf("Enter starting salary: ");
   scanf("%lf", &(data->startingSalary));
   getchar();
}

// stateTaxCalculator determines whether there is state income tax
void stateTaxCalculator(dataValues *data)
{
   char uinput;

   printf("Will you have state income tax? (y or n)\n");
   scanf("%c", &uinput);
   getchar();
   if (uinput == 'y') {
      printf("Enter state income tax as a percentage of your gross:\n");
      scanf("%lf", &(data->stateTax));
      getchar();
      data->statePayment = data->stateTax / 100.0 * 
                           data->startingSalary;
   } else if (uinput == 'n') {
      printf("No state income tax\n");
      data->stateTax = 0.0;
      data->statePayment = 0.0;
   } else {
      printf("Invalid input. Quitting program...\n");
   }
}

// SSTaxCalculator determines the total paid to Social Security
// 10.3% of first $65,000 of income paid to Social Security
// before taxes
void SSTaxCalculator(dataValues *data)
{
   if (data->startingSalary > SSMAX) {
      data->SSPayment = (SSPCTG / 100.0 * SSMAX);
   } else {
      data->SSPayment = (SSPCTG / 100.0 * data->startingSalary);
   }
}

// fedTaxCalculator determines the total paid in federal taxes
// $3,500 will be paid plus 28% of all income over $30,000
void fedTaxCalculator(dataValues *data)
{
   double taxable;

   data->fedPayment = FEDTAXMINPAY; 
   if (data->startingSalary > FEDTAXMIN) {
      taxable = data->startingSalary - FEDTAXMIN;
      data->fedPayment = data->fedPayment + (FEDTAXPCTG / 100.0 * taxable);
   }
}

// netIncomeCalculator finds the final net income value
void netIncomeCalculator(dataValues *data)
{
   data->netIncome = data->startingSalary;
   data->netIncome -= data->statePayment;
   data->netIncome -= data->SSPayment;
   data->netIncome -= data->fedPayment;
}

// debug prints out payment values
// debug functions as a check for appropriate values
void debug(dataValues *data)
{
   printf("State payment: %lf\n", data->statePayment);
   printf("SS payment: %lf\n", data->SSPayment);
   printf("Fed payment: %lf\n", data->fedPayment);
}
