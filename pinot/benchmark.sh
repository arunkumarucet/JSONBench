#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <TABLE_NAME> <RESULT_FILE_RUNTIMES>"
    exit 1
fi

TABLE_NAME="$1"
RESULT_FILE_RUNTIMES="$2"

QUERY_LOG_FILE="_query_log_${TABLE_NAME}.txt"

echo "Running queries on table: $TABLE_NAME"

./run_queries.sh "$TABLE_NAME" 2>&1 | tee "$QUERY_LOG_FILE"

RUNTIME_RESULTS=$(grep -E '^[0-9]' "$QUERY_LOG_FILE" | awk 'NR % 2 == 1' | awk '{
    if (NR % 3 == 1) { printf "["; }
    printf $1;
    if (NR % 3 == 0) {
        print "],";
    } else {
        printf ", ";
    }
}')

echo "$RUNTIME_RESULTS" > "$RESULT_FILE_RUNTIMES"
echo "Runtime results written to $RESULT_FILE_RUNTIMES"
