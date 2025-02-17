#!/bin/bash

# Default values
OUTPUT_FILE=""
DIR_PATH="/home/matth/Winter2025/CSCD43/A1"
SQL_FILE="$DIR_PATH/scripts/ScanQueries.sql"
BIN_DIR="/usr/local/pgsql/bin"

# Parse command line options
while getopts "i" opt; do
  case $opt in
    i) 
      # Flag to use index scan
      SQL_FILE="$DIR_PATH/scripts/IndexScanQueries.sql"
      ;;
    *)
      echo "Usage: $0 [-i] output_filename"
      exit 1
      ;;
  esac
done

# Shift positional parameters to get the output file name as the last argument
shift $((OPTIND - 1))

# Check if the output file name is provided as the last argument
if [ -z "$1" ]; then
  echo "Error: Output file name is required!"
  echo "Usage: $0 [-i] output_filename"
  exit 1
fi

# Set the output file to be in the ../outputs directory
OUTPUT_FILE="$DIR_PATH/outputs/$1.txt"

# Ensure the outputs directory exists
mkdir -p "$DIR_PATH/outputs"

# Run the PostgreSQL query file and output the result to the specified file
$BIN_DIR/psql -U postgres -d A1DB -f $SQL_FILE -o $OUTPUT_FILE

# Notify the user that the script has finished
echo "Queries have been executed and the output is saved to $OUTPUT_FILE"

