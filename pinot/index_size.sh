#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <TABLE_NAME>"
    exit 1
fi

TABLE_NAME="$1"

# Sum sizes of inverted index files (.bitmap) across all segments on disk
find ./data/server -name "*.bitmap" -o -name "*.mapping" 2>/dev/null \
    | xargs du -b 2>/dev/null \
    | awk '{sum += $1} END {print sum+0}'
