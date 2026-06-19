#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <TABLE_NAME>"
    exit 1
fi

TABLE_NAME="$1"
TRIES=3
BROKER_URL="http://localhost:8099/query/sql"

cat queries.sql | while read -r query; do

    echo "Clearing file system cache..."
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null
    echo "File system cache cleared."

    echo "Running query: $query"

    for i in $(seq 1 $TRIES); do
        START=$(date +%s%N)
        curl -s -X POST "$BROKER_URL" \
            -H 'Content-Type: application/json' \
            -d "{\"sql\": \"${query}\"}" > /tmp/pinot_query_result.json
        END=$(date +%s%N)

        ELAPSED=$(echo "scale=3; ($END - $START) / 1000000000" | bc)
        ROWS=$(cat /tmp/pinot_query_result.json | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('numRowsResultSet', 0))" 2>/dev/null || echo 0)
        echo "$ELAPSED"
        echo "$ROWS"
    done
done
