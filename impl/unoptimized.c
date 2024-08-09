#include <stdio.h>
#include <math.h>

#define K 16  // number of iterations

// Function to calculate log2(1 + 2^-i) and store it in a look-up table
void calculate_lut(double LUT[K]) {
    for (int i = 0; i < K; i++) {
        LUT[i] = log2(1 + pow(2, -i));
    }
}

// Function to compute the log2(M) using CCM (Convergence Computing Method)
double log2_CCM(double M) {
    double LUT[K];
    calculate_lut(LUT);  // Initialize the look-up table

    double f = 0;  // Initialize f to 0

    // Iterate from i = 0 to K-1
    for (int i = 0; i < K; i++) {
        double mu = M * (1 + pow(2, -i));  // Potential multiplication by Ai
        double phi = f - LUT[i];  // Potential subtraction with log2(Ai)

        // If mu <= 1.0, accept the iteration
        if (mu <= 1.0) {
            M = mu;
            f = phi;
        }
    }

    return f;  // Return the computed log2(M)
}

int main() {
    double M = 0.6;  // Example input value

    double result = log2_CCM(M);
    printf("Unoptimized log2(%f) = %f\n", M, result);

    return 0;
}
