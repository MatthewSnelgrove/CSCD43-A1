#!/bin/bash

# Check if a file argument is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi

LOG_FILE="$1"

# Check if the file exists
if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: File '$LOG_FILE' not found!"
    exit 1
fi

TOTAL_HITS=0
TOTAL_READS=0
PROCESS_NEXT_LINE=false

while IFS= read -r line; do
    if [[ "$PROCESS_NEXT_LINE" == true ]]; then
        # Extract hit and read values
        HITS=$(echo "$line" | grep -oP "hit=\d+" | awk -F= '{print $2}')
        READS=$(echo "$line" | grep -oP "read=\d+" | awk -F= '{print $2}')

        # Add to totals (default to 0 if empty)
        TOTAL_HITS=$((TOTAL_HITS + ${HITS:-0}))
        TOTAL_READS=$((TOTAL_READS + ${READS:-0}))

        # Reset flag
        PROCESS_NEXT_LINE=false
    fi

    # Check if the line is "Aggregate" or "Planning:"
    if [[ "$line" =~ ^" Aggregate  " || "$line" =~ ^" Planning:" ]]; then
        PROCESS_NEXT_LINE=true
    fi
done < "$LOG_FILE"

# Calculate hit rate (avoid division by zero)
TOTAL_ACCESSES=$((TOTAL_HITS + TOTAL_READS))
if [[ $TOTAL_ACCESSES -eq 0 ]]; then
    HIT_RATE=0
else
    HIT_RATE=$(awk "BEGIN {printf \"%.4f\", $TOTAL_HITS / $TOTAL_ACCESSES}")
fi

echo "Total Buffer Hits: $TOTAL_HITS"
echo "Total Buffer Reads: $TOTAL_READS"
echo "Hit Rate: $HIT_RATE"
