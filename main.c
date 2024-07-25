#include <stdio.h>
#include <math.h>
//NOTE: this version uses a scale factor of 2^62, as done in the progress report.

#define K 16
#define UNITY (1ULL << 62) // 2^62 as unity in fixed-point representation

// Function to compute log base 2 using CCM and fixed-point arithmetic
long long log_2_CCM(unsigned long long M_int) {
    int i;
    unsigned long long M_local_int;
    long long F_int;
    unsigned long long MU_int;
    long long PHI_int;

    M_local_int = M_int;
    F_int = 0;

    for (i = 0; i < (K - 2); i++) {
        unsigned long long LUT_value = (unsigned long long)(log2(1 + pow(2, -i)) * UNITY);
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
    unsigned long long M_int;
    long long log_2_M_int;
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

    M_int = (unsigned long long)(m_real * UNITY); // Use the new scale factor
    log_2_M_int = log_2_CCM(M_int);
    
    // Convert fixed-point to floating-point and adjust for normalization
    CCM_log_2_m_real = (double)log_2_M_int / UNITY + exponent;

    printf("M_int = %llu\n", M_int);
    printf("log_2_M_int = %lld\n", log_2_M_int);
    printf("CCM_log_2_m_real = %.15f\n", CCM_log_2_m_real);
    printf("Actual log2(m_real) = %.15f\n", log2(m_real) + exponent);

    return 0;
}
