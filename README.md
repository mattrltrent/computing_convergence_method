# Convergence Computing Method 🚀

SENG 440 @ [UVIC](https://uvic.ca)

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
