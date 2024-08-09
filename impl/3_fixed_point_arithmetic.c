#include <stdio.h>
#include <stdint.h>

// # of bits of precision
#define K 16
// 2^(K-1) represents our scale => 2^15 = 32768
#define SCALE_FACTOR (1 << (K - 1))  

void calculate_lut(int32_t LUT[K]) {
    for (int i = 0; i < K - 1; i++) {
        LUT[i] = (int32_t)(log2(1 + pow(2, -i)) * SCALE_FACTOR); 
    }
}

int32_t log2_CCM(int32_t M) {
    int32_t LUT[K];
    calculate_lut(LUT);

    int32_t f = 0; 

    for (int i = 0; i < K - 1; i++) {
        int32_t u = M + (M >> i);  
        int32_t phi = f - LUT[i];

        if (u <= SCALE_FACTOR) {
            M = u;
            f = phi;
        }
    }

    return f; 
}

int main() {
    double M_real = 0.6;  
    // convert to fixed-point notation
    int32_t M_fixed = (int32_t)(M_real * SCALE_FACTOR);

    int32_t result_fixed = log2_CCM(M_fixed);

    // revert to floating-point notation
    double result_real = (double)result_fixed / SCALE_FACTOR;

    printf("unoptimized fp ccm log2(%f) = %f\n", M_real, result_real);

    return 0;
}
