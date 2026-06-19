#!/bin/bash

echo "Dropping table bluesky"
curl -X DELETE "http://localhost:9000/tables/bluesky?type=offline"

echo "Deleting schema bluesky"
curl -X DELETE "http://localhost:9000/schemas/bluesky"

echo "Cleaning up segment and data directories"
rm -rf ./data/

./stop.sh
