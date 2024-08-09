#!/bin/bash

#! CONFIG THESE VARS
DEST_DIR="/home/matthew/remote_computing_convergence_method"
PI_USER="matthew"
PI_HOST="192.168.1.124"
SSH_KEY="~/.ssh/id_rsa"
#! CONFIG THESE VARS

clear

if [ -z "$1" ]; then
    echo "error, usage: ./run.sh <file.c>"
    exit 1
fi

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

# run compiled program with perf for report
REPORT_FILE="${PI_PATH%.c}_perf_report.txt"
ssh -i $SSH_KEY $PI_USER@$PI_HOST "perf stat -o $REPORT_FILE $OUT_FILE"

# gen report and scp back to local machine
if ssh -i $SSH_KEY $PI_USER@$PI_HOST "[ -f $REPORT_FILE ]"; then
    scp -i $SSH_KEY $PI_USER@$PI_HOST:$REPORT_FILE .
    echo "Performance report:"
    cat $(basename $REPORT_FILE)
else
    echo "Performance report file was not generated or could not be found."
fi

clear

ssh -t -i $SSH_KEY $PI_USER@$PI_HOST "$OUT_FILE"
