#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <TABLE_NAME>"
    exit 1
fi

TABLE_NAME="$1"

# Show segment metadata including index information
curl -s "http://localhost:9000/tables/${TABLE_NAME}/segments/metadata" \
    | python3 -c "
import sys, json
data = json.load(sys.stdin)
for segment in data:
    name = segment.get('segmentName', 'unknown')
    meta = segment.get('segmentMetadataDto', {})
    columns = meta.get('columns', [])
    for col in columns:
        col_name = col.get('columnName', '')
        has_inverted = col.get('hasInvertedIndex', False)
        has_json = col.get('hasJsonIndex', False)
        if has_inverted or has_json:
            print(f'{name}: {col_name} inverted={has_inverted} json={has_json}')
"
