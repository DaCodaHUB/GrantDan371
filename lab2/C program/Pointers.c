#include <stdio.h>
#include <stdlib.h>

int main() {

    int A = 22;
    int B = 17;
    int C = 6;
    int D = 4;
    int E = 9;
    int result = 0;
    int * Apointer = &A;
    int * Bpointer = &B;
    int * Cpointer = &C;
    int * Dpointer = &D;
    int * Epointer = &E;

    printf("A's address to point to: %p\n", (void*) &A);
    printf("B's address to point to: %p\n", (void*) &B);
    printf("C's address to point to: %p\n", (void*) &C);
    printf("D's address to point to: %p\n", (void*) &D);
    printf("E's address to point to: %p\n", (void*) &E);

    result = ((*Apointer * *Bpointer) * (*Cpointer * *Dpointer)) / *Epointer;
    printf("The result is: %d\n", result);
    return 1;
}
