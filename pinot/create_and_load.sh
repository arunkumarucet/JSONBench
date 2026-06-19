#!/bin/bash

if [[ $# -lt 6 ]]; then
    echo "Usage: $0 <DB_NAME> <TABLE_NAME> <DATA_DIRECTORY> <NUM_FILES> <SUCCESS_LOG> <ERROR_LOG>"
    exit 1
fi

DB_NAME="$1"
TABLE_NAME="$2"
DATA_DIRECTORY="$3"
NUM_FILES="$4"
SUCCESS_LOG="$5"
ERROR_LOG="$6"

[[ ! -d "$DATA_DIRECTORY" ]] && { echo "Error: Data directory '$DATA_DIRECTORY' does not exist."; exit 1; }
[[ ! "$NUM_FILES" =~ ^[0-9]+$ ]] && { echo "Error: NUM_FILES must be a positive integer."; exit 1; }

PINOT_VERSION="1.5.0"
PINOT_HOME="apache-pinot-${PINOT_VERSION}-bin"
PINOT_BIN="${PINOT_HOME}/bin/pinot-admin.sh"
CONTROLLER_URL="http://localhost:9000"

echo "Adding schema"
curl -X POST "${CONTROLLER_URL}/schemas" \
    -H 'Content-Type: application/json' \
    -d @config/schema.json

echo "Adding table"
curl -X POST "${CONTROLLER_URL}/tables" \
    -H 'Content-Type: application/json' \
    -d @config/table_config.json

echo "Loading data"
./load_data.sh "$DATA_DIRECTORY" "$DB_NAME" "$TABLE_NAME" "$NUM_FILES" "$SUCCESS_LOG" "$ERROR_LOG"
