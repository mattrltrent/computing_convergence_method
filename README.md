# Convergence Computing Method 🚀

SENG 440 @ [UVIC](https://uvic.ca)

## Note to marker

- Lots of this project's files are generated, or are not meant to be "final" since we tweak them often.
- The "final" optimized code is in `~/src/5_general_optimizations.c`.
- Please view the [report](https://hackmd.io/@mattrltrent/SJbsLhMq0) for details on what files looked like at each time.

## Running on a Raspberry Pi

1. Generate SSH keys on your local machine:

    ```bash
    ssh-keygen -t rsa -b 4096 -C "YOUR_EMAIL_ADDR"
    ```

2. Copy the public key to the Raspberry Pi:

    ```bash
    ssh-copy-id -i ~/.ssh/id_rsa.pub PI_NAME@PI_ADDR
    ```

3. Run the script (do this every time you want to run the program):

    ```bash
    ./run.sh ENTRY_FILE.c
    ```

## Accessing the Raspberry Pi

SSH into the Raspberry Pi:

```bash
ssh PI_NAME@PI_ADDR
```

