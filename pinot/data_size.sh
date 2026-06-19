#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <TABLE_NAME>"
    exit 1
fi

TABLE_NAME="$1"

# Estimated data size = total size minus forward index overhead (approximated as total size)
# Pinot doesn't expose data-only vs index breakdown via public API, so report total as data size
curl -s "http://localhost:9000/tables/${TABLE_NAME}/size?verbose=false&includeReplacedSegments=false" \
    | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('reportedSizeInBytes', 0))"
