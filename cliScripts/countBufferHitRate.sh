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

TOTAL_HITS_PERCENTAGE=0
CURRENT_HITS=0
CURRENT_READS=0
QUERY_COUNT=0
PROCESS_NEXT_LINE=false
TOTAL_EXECUTION_TIME=0

while IFS= read -r line; do
    if [[ "$PROCESS_NEXT_LINE" == true ]]; then
        # Extract hit and read values
        HITS=$(echo "$line" | grep -oP "hit=\d+" | awk -F= '{print $2}')
        READS=$(echo "$line" | grep -oP "read=\d+" | awk -F= '{print $2}')

        # Add to totals (default to 0 if empty)
        CURRENT_HITS=$((CURRENT_HITS + ${HITS:-0}))
        CURRENT_READS=$((CURRENT_READS + ${READS:-0}))

    fi

    # Reset flag
    PROCESS_NEXT_LINE=false

    # Check if the line is "Aggregate" or "Planning:"
    if [[ "$line" =~ ^" Aggregate  " ]]; then
        PROCESS_NEXT_LINE=true
    fi

    # Check if start of new query and query count is greater than 0
    if [[ "$line" =~ "QUERY PLAN" ]]; then
        QUERY_COUNT=$((QUERY_COUNT + 1))
        if [[ $QUERY_COUNT -eq 1 ]]; then
            continue
        fi
        # float division
        HIT_RATE=$(bc -l <<< "scale=4; $CURRENT_HITS / ($CURRENT_HITS + $CURRENT_READS)")
        TOTAL_HITS_PERCENTAGE=$(bc -l <<< "scale=4; $TOTAL_HITS_PERCENTAGE + $HIT_RATE")
        CURRENT_HITS=0
        CURRENT_READS=0
    fi

    # Add to total execution time
    if [[ "$line" =~ "Execution Time" ]]; then
        EXECUTION_TIME=$(echo "$line" | grep -oP "\d+\.\d+" | awk '{print $1}')
        TOTAL_EXECUTION_TIME=$(bc -l <<< "scale=4; $TOTAL_EXECUTION_TIME + $EXECUTION_TIME")
    fi
done < "$LOG_FILE"

# Compute for final query
HIT_RATE=$(bc -l <<< "scale=4; $CURRENT_HITS / ($CURRENT_HITS + $CURRENT_READS)")
TOTAL_HITS_PERCENTAGE=$(bc -l <<< "scale=4; $TOTAL_HITS_PERCENTAGE + $HIT_RATE")

AVERAGE_HIT_RATE=$(bc -l <<< "scale=4; $TOTAL_HITS_PERCENTAGE / $QUERY_COUNT")
AVERAGE_MISS_RATE=$(bc -l <<< "scale=4; 1 - $AVERAGE_HIT_RATE")

AVERAGE_EXECUTION_TIME=$(bc -l <<< "scale=4; $TOTAL_EXECUTION_TIME / $QUERY_COUNT")

echo "Average Hit Rate: $AVERAGE_HIT_RATE"
echo "Average Miss Rate: $AVERAGE_MISS_RATE"
echo "Average Execution Time: $AVERAGE_EXECUTION_TIME"
