#!/bin/bash
BIN_DIR="/usr/local/pgsql/bin"
DATA_DIR="/usr/local/pgsql/data"

echo "Stopping PostgreSQL server..."
sudo -u postgres $BIN_DIR/pg_ctl -D $DATA_DIR stop
