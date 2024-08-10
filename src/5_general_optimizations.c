#include <stdio.h>
#include <stdint.h>

#define K 16
#define SCALE_FACTOR (1 << (K - 1))

int main() {
    register int32_t M = 19660;
    register int32_t f = 0;
    int32_t LUT[K - 1] = {32768, 19168, 10548, 5568, 2865, 1454, 732, 367, 184, 92, 46, 23, 11, 5, 2};

    // normalization of M to range [0.5, 1.0)
    while (M < SCALE_FACTOR / 2) {
        M <<= 1;
    }

    // loop unrolling and pipelining
    for (register int i = 0; i < K - 1; i += 2) {
        // first loop unroll iter
        register int32_t u1 = M + (M >> i);
        register int32_t LUT_val1 = LUT[i];
        if (u1 <= SCALE_FACTOR) {
            M = u1;
            f -= LUT_val1;
        }

        // prep for the next loop unroll iter
        if (i + 1 < K - 1) {
            register int32_t u2 = M + (M >> (i + 1));
            register int32_t LUT_val2 = LUT[i + 1];
            if (u2 <= SCALE_FACTOR) {
                M = u2;
                f -= LUT_val2;
            }
        }
    }

    printf("optimized fp ccm log2(%f) = %f\n", 0.6, (double)f / SCALE_FACTOR);

    return 0;
}
