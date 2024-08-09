#!/bin/bash

clear

if [ -z "$1" ]; then
    echo "No file provided. Usage: ./run.sh <file_to_run.c>"
    exit 1
fi

SOURCE_DIR=$(dirname "$0")

DEST_DIR="/home/matthew/remote_computing_convergence_method"

PI_USER="matthew"
PI_HOST="192.168.1.124"
SSH_KEY="~/.ssh/id_rsa"

ssh -i $SSH_KEY $PI_USER@$PI_HOST "mkdir -p $DEST_DIR" 2>/dev/null

scp -i $SSH_KEY -r $SOURCE_DIR/* $PI_USER@$PI_HOST:$DEST_DIR 2>/dev/null

RUN_FILE="$DEST_DIR/$(basename $1)"
ssh -i $SSH_KEY $PI_USER@$PI_HOST "gcc $RUN_FILE -o ${RUN_FILE%.c}.out -lm" 2>/dev/null

clear

ssh -t -i $SSH_KEY $PI_USER@$PI_HOST "${RUN_FILE%.c}.out" 2>/dev/null
