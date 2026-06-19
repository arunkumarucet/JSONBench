#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <TABLE_NAME>"
    exit 1
fi

TABLE_NAME="$1"

# Returns total segment size in bytes via Pinot controller API
curl -s "http://localhost:9000/tables/${TABLE_NAME}/size?detailed=false" \
    | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('reportedSizeInBytes', 0))"
