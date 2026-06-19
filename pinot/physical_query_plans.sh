#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <TABLE_NAME>"
    exit 1
fi

TABLE_NAME="$1"

cat queries.sql | while read -r query; do
    echo "Query: $query"
    curl -s -X POST "http://localhost:8099/query/sql" \
        -H 'Content-Type: application/json' \
        -d "{\"sql\": \"EXPLAIN PLAN FOR ${query}\"}" \
        | python3 -c "
import sys, json
d = json.load(sys.stdin)
rows = d.get('resultTable', {}).get('rows', [])
for row in rows:
    print('\t'.join(str(x) for x in row))
"
    echo ""
done
