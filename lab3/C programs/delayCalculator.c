#include <stdio.h>

int main() {
    int deviceNum = -1;
    int traces = 0;
    float output = 0;

    while (deviceNum < 0) {
        printf("Please input the number of device on your circuit\n");
        scanf("%d", &deviceNum);
    }

    if (deviceNum == 0) {
        printf("\nThe delay is 0 seconds\n");
        return 1;
    }

    traces = 18 * (deviceNum - 1);
    output = traces + deviceNum * 5000;

    printf("\nThe total delay is %.0f picoseconds =", output);
    output = output / 1000;
    printf(" %.3f nanoseconds =", output);
    printf(" %.3f * 10^-9 seconds\n", output);

    return 1;
}
