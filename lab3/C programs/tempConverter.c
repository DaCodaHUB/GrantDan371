#include <stdio.h>

int clean_stdin();

int main() {
    float temp = 0;
    int choose1 = -1;
    int choose2 = -1;
    float celsius = 0;
    int convert = 0;

    printf("Please enter the temperature value\n");
    scanf("%f", &temp);

    printf("\nPlease enter the scale of the temperature\n");
    printf("1 for Celsius\n");
    printf("2 for Fahrenheit\n");
    printf("3 for Kelvin\n");

    while (choose1 < 0 || choose1 > 3) {
        printf("\nPlease enter 1, 2 or 3\n");
        scanf("%d", &choose1);
    }

    if (choose1 == 1)
        celsius = temp;
    else if (choose1 == 2)
        celsius = (temp - 32) * 5/9;
    else if (choose1 == 3)
        celsius = temp - 273.15;

    printf("\nPlease enter the scale of the temperature to convert\n");
    printf("1 for Celsius\n");
    printf("2 for Fahrenheit\n");
    printf("3 for Kelvin\n");

    while (choose2 < 0 || choose2 > 3) {
        printf("\nPlease enter 1, 2 or 3\n");
        scanf("%d", &choose2);
    }

    printf("\n%.2f ", temp);
    if (choose1 == 1)
        printf("Celsius ");
    else if (choose1 == 2)
        printf("Fahrenheit ");
    else if (choose1 == 3)
        printf("Kelvin ");

    if (choose2 == 1) 
        temp = celsius;
    else if (choose2 == 2)
        temp = (celsius * 9/5) + 32;
    else if (choose2 == 3)
        temp = celsius + 273.15;

    printf("converted to %.2f ", temp);

    if (choose2 == 1)
        printf("Celsius\n");
    else if (choose2 == 2)
        printf("Fahrenheit\n");
    else if (choose2 == 3)
        printf("Kelvin\n");

    return 1;
}

int clean_stdin()
{
    while (getchar()!='\n');
    return 1;
}

