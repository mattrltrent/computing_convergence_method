#include <stdio.h>
#include <stdint.h>

#define K 16
#define SCALE_FACTOR (1 << (K - 1))

int main()
{
    // register int32_t M = (int32_t)(0.6 * SCALE_FACTOR); // 0.6 -> 19660
    register int32_t M = 19660;
    register int32_t f = 0;  
    int32_t LUT[K - 1]  = {32768, 19168, 10548, 5568, 2865, 1454, 732, 367, 184, 92, 46, 23, 11, 5, 2};

    // normalization of M to range [0.5, 1.0)
    while (M < SCALE_FACTOR / 2)
    {
        M <<= 1;
    }

    // loop unrolling and software pipelining to optimize the cyclic multiplication
    for (register int i = 0; i < K - 2; i += 2)
    {   
        // print ITER
        // printf("ITER: %d\n", i);
        register int32_t u1 = M + (M >> i);
        register int32_t LUT_val1 = LUT[i];
        register lteSF1 = u1 <= SCALE_FACTOR;
        M = lteSF1 ? u1 : M;
        f = lteSF1 ? f - LUT_val1 : f;

        register int32_t u2 = M + (M >> (i+1));
        register int32_t LUT_val2 = LUT[i + 1];
        register lteSF2 = u2 <= SCALE_FACTOR;
        M = (lteSF2) ? u2 : M;
        f = (lteSF2) ? f - LUT_val2 : f;
    }

    // // handling the last iteration if the loop count is odd
    // if (K % 2 == 0) {
    //     register int32_t u = M + (M >> (K-2));
    //     register int32_t LUT_val = LUT[K - 2];
    //     M = (u <= SCALE_FACTOR) ? u : M;
    //     f = (u <= SCALE_FACTOR) ? f - LUT_val : f;
    // }

    printf("optimized fp ccm log2(%f) = %f\n", 0.6, (double)f / SCALE_FACTOR);

    return 0;
}
