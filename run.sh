#!/bin/bash

#! configure these vars yourself
DEST_DIR="/home/matthew/remote_computing_convergence_method"
PI_USER="matthew"
PI_HOST="192.168.1.124"
SSH_KEY="~/.ssh/id_rsa"
#! configure these vars yourself

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

clear
ssh -t -i $SSH_KEY $PI_USER@$PI_HOST "$OUT_FILE"