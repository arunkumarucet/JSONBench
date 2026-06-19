#!/bin/bash

if [[ $# -lt 6 ]]; then
    echo "Usage: $0 <DATA_DIRECTORY> <DB_NAME> <TABLE_NAME> <MAX_FILES> <SUCCESS_LOG> <ERROR_LOG>"
    exit 1
fi

DATA_DIRECTORY="$1"
DB_NAME="$2"
TABLE_NAME="$3"
MAX_FILES="$4"
SUCCESS_LOG="$5"
ERROR_LOG="$6"

[[ ! -d "$DATA_DIRECTORY" ]] && { echo "Error: Data directory '$DATA_DIRECTORY' does not exist."; exit 1; }
[[ ! "$MAX_FILES" =~ ^[0-9]+$ ]] && { echo "Error: MAX_FILES must be a positive integer."; exit 1; }

PINOT_VERSION="1.5.0"
PINOT_HOME="apache-pinot-${PINOT_VERSION}-bin"
PINOT_BIN="${PINOT_HOME}/bin/pinot-admin.sh"

INPUT_DIR=$(mktemp -d /var/tmp/pinot_input.XXXXXX)
SEGMENT_DIR=$(mktemp -d /var/tmp/pinot_segments.XXXXXX)
trap "rm -rf $INPUT_DIR $SEGMENT_DIR" EXIT

# Symlink the first MAX_FILES .json.gz files into INPUT_DIR — no decompression needed,
# Pinot's JSONRecordReader detects .gz by extension
counter=0
for file in $(ls "$DATA_DIRECTORY"/*.json.gz | head -n "$MAX_FILES"); do
    ln -s "$(realpath "$file")" "$INPUT_DIR/$(basename "$file")"
    counter=$((counter + 1))
done
echo "Prepared $counter files for ingestion"

cat > "/tmp/pinot_job_spec.yaml" <<EOF
executionFrameworkSpec:
  name: 'standalone'
  segmentGenerationJobRunnerClassName: 'org.apache.pinot.plugin.ingestion.batch.standalone.SegmentGenerationJobRunner'
  segmentTarPushJobRunnerClassName: 'org.apache.pinot.plugin.ingestion.batch.standalone.SegmentTarPushJobRunner'

jobType: SegmentCreationAndTarPush

inputDirURI: 'file://${INPUT_DIR}'
outputDirURI: 'file://${SEGMENT_DIR}'
overwriteOutput: true

pinotFSSpecs:
  - scheme: file
    className: org.apache.pinot.spi.filesystem.LocalPinotFS

recordReaderSpec:
  dataFormat: 'json'
  className: 'org.apache.pinot.plugin.inputformat.json.JSONRecordReader'

tableSpec:
  tableName: '${TABLE_NAME}'
  schemaURI: 'http://localhost:9000/schemas/${TABLE_NAME}'
  tableConfigURI: 'http://localhost:9000/tables/${TABLE_NAME}'

pinotClusterSpecs:
  - controllerURI: 'http://localhost:9000'

pushJobSpec:
  pushAttempts: 2
  pushRetryIntervalMillis: 1000
EOF

JAVA_OPTS="-Xms4g -Xmx16g" ${PINOT_BIN} LaunchDataIngestionJob \
    -jobSpecFile "/tmp/pinot_job_spec.yaml"

if [[ $? -eq 0 ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Successfully ingested $counter files." >> "$SUCCESS_LOG"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Ingestion job failed." >> "$ERROR_LOG"
    exit 1
fi

rm -f "/tmp/pinot_job_spec.yaml"
