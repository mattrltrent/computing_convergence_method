#include <stdio.h>
#include <math.h>

// # of bits of precision
#define K 16

void calculate_lut(double LUT[K]) {
    for (int i = 0; i < K - 1; i++) {
        LUT[i] = log2(1 + pow(2, -i));
    }
}

double log2_CCM(double M) {
    double LUT[K];
    calculate_lut(LUT);

    double f = 0; 

    for (int i = 0; i < K - 1; i++) {
        double u = M * (1 + pow(2, -i)); 
        double phi = f - LUT[i];  

        if (u <= 1.0) {
            M = u;
            f = phi;
        }
    }

    return f; 
}

int main() {
    double M = 0.6;  

    printf("unoptimized ccm log2(%f) = %f\n", M, log2_CCM(M));

    return 0;
}
