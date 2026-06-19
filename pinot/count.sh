#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <TABLE_NAME>"
    exit 1
fi

TABLE_NAME="$1"

curl -s -X POST "http://localhost:8099/query/sql" \
    -H 'Content-Type: application/json' \
    -d "{\"sql\": \"SELECT count(*) FROM ${TABLE_NAME}\"}" \
    | python3 -c "import sys, json; d=json.load(sys.stdin); print(d['resultTable']['rows'][0][0])"
