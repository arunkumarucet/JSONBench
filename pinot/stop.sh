#!/bin/bash

echo "Stopping Pinot processes"
pkill -f "pinot-admin.sh" || true
pkill -f "PinotController" || true
pkill -f "PinotBroker" || true
pkill -f "PinotServer" || true
pkill -f "QuorumPeerMain" || true

sleep 5
echo "Pinot stopped."
