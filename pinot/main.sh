#!/bin/bash

DEFAULT_CHOICE=ask
DEFAULT_DATA_DIRECTORY=~/data/bluesky

CHOICE="${1:-$DEFAULT_CHOICE}"
DATA_DIRECTORY="${2:-$DEFAULT_DATA_DIRECTORY}"
SUCCESS_LOG="${3:-success.log}"
ERROR_LOG="${4:-error.log}"
OUTPUT_PREFIX="${4:-_m6i.8xlarge}"

if [[ ! -d "$DATA_DIRECTORY" ]]; then
    echo "Error: Data directory '$DATA_DIRECTORY' does not exist."
    exit 1
fi

if [ "$CHOICE" = "ask" ]; then
    echo "Select the dataset size to benchmark:"
    echo "1) 1m (default)"
    echo "2) 10m"
    echo "3) 100m"
    echo "4) 1000m"
    echo "5) all"
    read -p "Enter the number corresponding to your choice: " CHOICE
fi

./install.sh

benchmark() {
    local size=$1
    file_count=$(find "$DATA_DIRECTORY" -type f | wc -l)
    if (( file_count < size )); then
        echo "Error: Not enough files in '$DATA_DIRECTORY'. Required: $size, Found: $file_count."
        exit 1
    fi
    ./start.sh
    ./create_and_load.sh "bluesky_${size}m" bluesky "$DATA_DIRECTORY" "$size" "$SUCCESS_LOG" "$ERROR_LOG"
    ./total_size.sh bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.total_size"
    ./data_size.sh bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.data_size"
    ./index_size.sh bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.index_size"
    ./count.sh bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.count"
    ./index_usage.sh bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.index_usage"
    ./physical_query_plans.sh bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.physical_query_plans"
    ./benchmark.sh bluesky "${OUTPUT_PREFIX}_bluesky_${size}m.results_runtime"
    ./drop_table.sh
}

case $CHOICE in
    2)
        benchmark 10
        ;;
    3)
        benchmark 100
        ;;
    4)
        benchmark 1000
        ;;
    5)
        benchmark 1
        benchmark 10
        benchmark 100
        benchmark 1000
        ;;
    *)
        benchmark 1
        ;;
esac
