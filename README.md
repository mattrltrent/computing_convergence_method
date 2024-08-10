# Convergence computing method

[Matthew Trent](https://matthewtrent.me) (V00982038, CSC) · [Gabriel Maryshev](https://github.com/AcademicianZakharov) (V00993574, CSC)

[University of Victoria](https://uvic.ca)

Submission date: \_ \_ \_ \_ \_ \_ \_ \_ \_ \_ \_ \_

![banner](https://raw.githubusercontent.com/mattrltrent/random_assets/main/tech.jpg)

## Abstract

todo at end

## Table of contents

todo at end

## Introduction

For our [SENG 440](https://www.uvic.ca/calendar/undergrad/index.php#/courses/HJ_ylKaQV?q=seng440&&limit=20&skip=0&bc=true&bcCurrent=&bcCurrent=Embedded%20Systems&bcItemType=courses) term project at the [University of Victoria](https://uvic.ca) we decided to tackle the Convergence Computing Method (CCM). This is a technique for calculating transcendental functions such as logarithms, exponentials, or $n$-th roots [4]. It does so through an iterative “shift and add”-type approach. This makes it highly efficient and performant compared to traditional techniques.

Inherently, CCM is a fixed-point arithmetic method. Thus, it maps real numbers to integers. This is done by multiplying the input real number by a scaling factor, doing all the computations in this integer space, then dividing by the scaling factor at the end. Such is done to avoid floating-point arithmetic, which as we've learned in this class, is slow, computationally expensive and requires specialized hardware.

Since both members of our group own and actively use [Raspberry Pi](https://www.raspberrypi.com/) boards, we decided to tailor our CCM implementation to this specific hardware. Specifically, we are developing our solution for the Raspberry Pi 4 B 8GB board with a Broadcom BCM2711 SoC. This SoC has a 1.8 GHz 64-bit quad-core ARM Cortex-A72, with a 1MB shared L2 cache [1]. It's a 64-bit, arm64, ARMv8-A architecture. We are using `gcc` as our compiler.

Our workflow this term has been interesting. We used [Discord](https://discord.com/) for communication, [GitHub](https://github.com) for syncing code, [Visual Studio Code](https://code.visualstudio.com/) for coding, [HackMD](https://hackmd.io) for real-time writing of documentation, and of course the Raspberry Pi for running our code. On startup, we also downloaded the official Raspberry Pi Imager to flash the Raspberry Pi OS to an SD card to boot the Pi. Further, we used `ssh` to connect to the Pi and `scp` to transfer files back and forth.

## Design requirements

After thoroughly analyzing the slides [4] on the Convergence Computing Method Dr. Sima provided us at the start of the term, we derived the following requirements:

- We need to select one of four transcendental functions to perform CCM on: $log_2(M)$, $e^M$, $M^{1/2}$, or $M^{1/3}$. We chose the logarithm.
- We need to take in inputs wider than the ideal theoretical range.
- CCM needs to be implemented using fixed-point arithmetic.
- Determine the bottleneck in the CCM algorithm.
- Figure out a new instruction(s) to improve the performance of the bottleneck.
- ~~Implement the new instruction(s) in the hardware.~~ (Requirement deprecated.)
- Rewrite high-level code to use the new new instruction(s). This should include assembly in-lining.
- Determine the speedup of the new implementation.

## Hardware

Here is a summarization of the hardware we talked about above for clarity:

- Raspberry Pi 4 B 8GB board.
- Broadcom BCM2711 SoC with a 1.8 GHz 64-bit quad-core ARM Cortex-A72, with a 1MB shared L2 cache [1].
- 64-bit, arm64, ARMv8-A.
- `gcc` as compiler.

## Design choices

Since our processor has a 64-bit architecture, we could've decided to use 64-bit integers for our fixed-point arithmetic. However, we realized this was likely unnecessary. In practice, the precision improvement that comes with this increased bti width is negligible due to simple user requirements as well as the CCM algorithm itself. Further, using larger integers would slow down our code and double the required memory. Thus, we decided to optimize for speed and memory while maintaining alright precision by using 32-bit integers.

## Running our code on an embedded system

As established before, we're running our code on our personal Raspberry Pi. Ergo, we needed an easy way to transfer files back and forth between it and our local machines, as well as run those files.

![pi](https://raw.githubusercontent.com/mattrltrent/random_assets/main/pi2.JPG)

To solve this, we developed a quick `run.sh` script. It looks as follows:

```bash
#!/bin/bash

#! CONFIG THESE VARS
DEST_DIR="/home/matthew/remote_computing_convergence_method"
PI_USER="matthew"
PI_HOST="192.168.1.124"
SSH_KEY="~/.ssh/id_rsa"
LOCAL_STATS_DIR="./stats"
#! CONFIG THESE VARS

clear

if [ -z "$1" ]; then
    echo "error, usage: ./run.sh <file.c>"
    exit 1
fi

mkdir -p "$LOCAL_STATS_DIR"

SOURCE_DIR=$(dirname "$0")
FILE_PATH="$1"
FILE_DIR=$(dirname "$FILE_PATH")
FILE_NAME=$(basename "$FILE_PATH")

PI_PATH="$DEST_DIR/$FILE_DIR/$FILE_NAME"

ssh -i $SSH_KEY $PI_USER@$PI_HOST "mkdir -p $DEST_DIR/$FILE_DIR"
scp -i $SSH_KEY -r $SOURCE_DIR/* $PI_USER@$PI_HOST:$DEST_DIR
ssh -i $SSH_KEY $PI_USER@$PI_HOST "ls -lR $DEST_DIR"

OUT_FILE="${PI_PATH%.c}.out"

ssh -i $SSH_KEY $PI_USER@$PI_HOST "gcc $PI_PATH -o $OUT_FILE -lm"

COMPILATION_STATUS=$?
if [ $COMPILATION_STATUS -ne 0 ]; then
    echo "Compilation failed. Exiting."
    exit 1
fi

REPORT_FILE="${PI_PATH%.c}_perf_report.txt"
ssh -i $SSH_KEY $PI_USER@$PI_HOST "perf stat -o $REPORT_FILE $OUT_FILE"

if ssh -i $SSH_KEY $PI_USER@$PI_HOST "[ -f $REPORT_FILE ]"; then
    scp -i $SSH_KEY $PI_USER@$PI_HOST:$REPORT_FILE "$LOCAL_STATS_DIR/"
    cat "$LOCAL_STATS_DIR/$(basename $REPORT_FILE)"
else
    echo "Performance report file was not generated or could not be found."
fi

clear

ssh -t -i $SSH_KEY $PI_USER@$PI_HOST "$OUT_FILE"
```

From here, running the script is as simple as:

```bash
./run.sh some/file/path/some_file.c
```

This then executes the listed file on the Raspberry Pi, and returns the output to our local machine. Note that we are running our code using the standard `gcc` compiler, outputting an object file, and then linking it with the math library via the `-lm` flag. It also uses [`perf`](https://perf.wiki.kernel.org/index.php/Main_Page) to generate a performance report for execution under the `~/stats` directory.

## Implementation

We started by creating a control implementation that solely utilized C's default `<math.h>` `log2` function to use as a baseline for comparing the efficacy of our subsequent iterations:

```c
#include <stdio.h>
#include <math.h>

int main() {
    double M = 0.6;

    printf("base log2(%f) = %f\n", M, log2(M));

    return 0;
}
```

Running this with `M` as `0.6` output:

```
base log2(0.600000) = -0.736966
```

With this completed, we began to prototype an unoptimized CCM implementation based directly off Dr. Sima's provided pseudocode [4]:

![binary logarithm psuedocode](https://raw.githubusercontent.com/mattrltrent/random_assets/main/pseudo.png)

After some initial confusion regarding bit precision, we arrived at the following implementation:

```c
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

    printf("unoptimized log2(%f) = %f\n", M, log2_CCM(M));

    return 0;
}
```

It's worth noting this raw, unoptimized version evidently didn't utilize floating-point arithmetic. When running it with `M` as `0.6`, it output:

```
unoptimized ccm log2(0.600000) = -0.736927
```

This looked right, as it only differed from the baseline value by:

$$
||-0.736927 - -0.736966| / ((-0.736927 + -0.736966) / 2) * 100|
$$

$$
= 0.00529211\%
$$

This is a reasonable amount considering we expected to lose out on a little bit of precision due to switching to CCM with only `K=16` bits of precision. We verified these bits were the reason for our answer variance, as when we increased `K` to some larger number, like `K=25`, we got 0% difference when comparing against the baseline function.

## Optimizations

Now that we had a working CCM function, we needed to optimize. For us, the file structure we used to keep track of our progressive optimizations was as follows:

```
├── impl
│   ├── 1_base.c
│   └── 2_unoptimized.c
│   └── 3_
│   └── ...
│   └── n_
```

Where each new line represented the copy-and-pasted prior version, with some new "feature(s)" making it more performant than before.

First and foremost, this meant introducing floating-point arithmetic. In the end, our code looked as follows:

```c
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
```

Given our earlier reasons for wanting to use 32-bit integers over 64-bit integers on our 64-bit architecture, we elected our `SCALE_FACTOR` to be $2^{15}$. This is because of the way 32 bits are divided between integer, fractional, and sign bits for fixed-point arithmetic. This is highlighted in the table below:

| **Bit positions (from right)** | **Allocated bits** | **Purpose**               | **Description**                                                  |
| ----------------------------- | ------------------ | ------------------------- | ---------------------------------------------------------------- |
| 31st                           | 1 bit              | Number's sign             | Indicates if the number is positive or negative.                     |
| 30th - 15th                    | 16 bits            | Integer part of number    | Represents the integer portion of the number, capable of storing values from $-2^{15}$ to $2^{15} - 1$ ($-32,768$ to $32,767$). |
| 14th - 0th                     | 15 bits            | Fractional part of number | Provides fractional precision using a scale factor of $2^{15}$, meaning 15 bits of fractional precision. |

Testing this implementation, it outputs:

```
unoptimized fp ccm log2(0.600000) = -0.736938
```

Which, using the same percentage difference formula we used last time, and compared against the baseline `<math.h>` `log2`, this yields a 0.00379943% difference. Surprisingly, this is a smaller value, and hence a more accurate approximation to the true logarithm compared to our previous unoptimized version of CCM we had before that did not use fixed-point arithmetic.

Next, we switched the calculation time of the lookup table (LUT) from runtime to being pre-calculated. To do this, we swapped out this:

```c
void calculate_lut(int32_t LUT[K]) {
    for (int i = 0; i < K - 1; i++) {
        LUT[i] = (int32_t)(log2(1 + pow(2, -i)) * SCALE_FACTOR); 
    }
}
```

With:

```c
const int32_t LUT[K-1] = {
    32768, 19168, 10548, 5568, 2865, 1454, 732, 
    367, 184, 92, 46, 23, 11, 5, 2
};
```

We determined these `LUT` values via a small Python script:

```python
import math
print(", ".join(map(str, [int(math.log2(1 + math.pow(2, -i)) * (1 << 15)) for i in range(15)])))   
```

Which outputted:

```
32768, 19168, 10548, 5568, 2865, 1454, 732, 367, 184, 92, 46, 23, 11, 5, 2
```

After this, our next big step was to implement Single Instruction Multiple Data (SIMD) via NEON. Our aim with this was to vectorize certain operations so that we could run them in parallel, opposed to strictly sequentially. Thankfully, upon checking the [documentation](https://developer.arm.com/documentation/102474/latest), our Raspberry Pi's arm64 processor did have support for these kinds of operations! To be extra certain, I also connected to the Pi and inspected its `cpuinfo` file:

```bash
matthew@pi:~ $ cat /proc/cpuinfo | grep Features
```

This, as expected, listed out 4 processors, each with `asimd` capabilities. To be specific, these are actually *advanced* SIMDs, hence their "a" prefix [6]:

```
Features	: fp asimd evtstrm crc32 cpuid
Features	: fp asimd evtstrm crc32 cpuid
Features	: fp asimd evtstrm crc32 cpuid
Features	: fp asimd evtstrm crc32 cpuid
```

To run NEON code, we also added the `-march=armv8-a+simd` flag to our `gcc` build and run command. This instructs the compiler to use the ARMv8-A architecture with SIMD instructions enabled. Here is what our new SIMD-optimized code looked like:

```c
// todo
```

The goal of this implementation step was to 

### Speedup

### Profiling

### Valgrind

### Cachegrind

#### Performance chart

### Numerical accuracy

### Rounding

### Predicate operations

### Discussion

#### Future work

### Conclusion

### Bibliography

### References

- [1] https://en.wikipedia.org/wiki/Raspberry_Pi
- [2] https://pi.processing.org/technical/
- [3] https://www.quora.com/Which-instruction-set-architecture-is-used-in-Raspberry-Pi-4
- [4] Professor’s CCM slides
- [5] https://en.wikipedia.org/wiki/Integer_overflow
- [6] https://developer.arm.com/Architectures/Neon
