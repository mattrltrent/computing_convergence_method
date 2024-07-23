#include <stdio.h>
#include <math.h>

// Define constants
#define K 16
#define UNITY (1 << 14) // 2^14 as unity in fixed-point representation

// Function to compute log base 2 using CCM and fixed-point arithmetic
int log_2_CCM(int M_int) {
    int i;
    int M_local_int;
    int F_int;
    int MU_int;
    int PHI_int;
    M_local_int = M_int;
    F_int = 0;
    for (i = 0; i < (K-2); i++) {
        int LUT_value = (int)(log2(1 + pow(2, -i)) * UNITY);
        MU_int = M_local_int + (M_local_int >> i);
        PHI_int = F_int - LUT_value;
        if (MU_int <= UNITY) {
            M_local_int = MU_int;
            F_int = PHI_int;
        }
    }
    return F_int;
}

int main() {
    double m_real;
    int M_int;
    int log_2_M_int;
    double CCM_log_2_m_real;
    int exponent = 0;

    printf("Enter the real argument m_real, where 0.25 <= m_real < 2.0: ");
    scanf("%lf", &m_real);

    if (m_real < 0.25 || m_real >= 2.0) {
        printf("Input out of range. Please enter a value between 0.25 and 2.0\n");
        return 1;
    }

    // Normalize the input to be in the range [0.5, 1)
    while (m_real < 0.5) {
        m_real *= 2;
        exponent--;
    }
    while (m_real >= 1.0) {
        m_real /= 2;
        exponent++;
    }

    M_int = (int)(m_real * UNITY);
    log_2_M_int = log_2_CCM(M_int);
    
    // Convert fixed-point to floating-point and adjust for normalization
    CCM_log_2_m_real = (double)log_2_M_int / UNITY + exponent;

    printf("M_int = %d\n", M_int);
    printf("log_2_M_int = %d\n", log_2_M_int);
    printf("CCM_log_2_m_real = %.15f\n", CCM_log_2_m_real);

    // Print the actual log2 for comparison
    printf("Actual log2(m_real) = %.15f\n", log2(m_real) + exponent);

    return 0;
}