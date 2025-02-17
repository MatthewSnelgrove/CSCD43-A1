#!/bin/bash
BIN_DIR="/usr/local/pgsql/bin"
DATA_DIR="/usr/local/pgsql/data"

# Check if the number of buffers is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <num_buffers>"
    exit 1
fi

NUM_BUFFERS=$1

# Run PostgreSQL with the specified number of buffers
sudo -u postgres $BIN_DIR/postgres -B "$NUM_BUFFERS" -D $DATA_DIR
