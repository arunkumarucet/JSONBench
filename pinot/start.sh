#!/bin/bash

PINOT_VERSION="1.5.0"
PINOT_HOME="apache-pinot-${PINOT_VERSION}-bin"
PINOT_BIN="${PINOT_HOME}/bin/pinot-admin.sh"

DATA_DIR="$(pwd)/data"
PID_DIR="$(pwd)/pids"
mkdir -p "${DATA_DIR}/controller" "${DATA_DIR}/server/segments" "${PID_DIR}"

echo "Starting Zookeeper"
JAVA_OPTS="-Xms2g -Xmx2g" ${PINOT_BIN} StartZookeeper -zkPort 2181 &
echo $! > "${PID_DIR}/zookeeper.pid"
sleep 5

echo "Starting Controller"
JAVA_OPTS="-Xms2g -Xmx2g" ${PINOT_BIN} StartController \
    -zkAddress localhost:2181 \
    -controllerPort 9000 \
    -dataDir "${DATA_DIR}/controller" &
echo $! > "${PID_DIR}/controller.pid"

echo "Waiting for Controller to be ready..."
for i in $(seq 1 60); do
    if curl -sf "http://localhost:9000/health" | grep -q "OK"; then
        echo "Controller is ready"
        break
    fi
    echo "  waiting... ($i/60)"
    sleep 3
done

echo "Starting Broker"
JAVA_OPTS="-Xms4g -Xmx4g" ${PINOT_BIN} StartBroker \
    -zkAddress localhost:2181 \
    -brokerPort 8099 &
echo $! > "${PID_DIR}/broker.pid"

echo "Starting Server"
JAVA_OPTS="-Xms48g -Xmx48g -XX:MaxDirectMemorySize=48g" ${PINOT_BIN} StartServer \
    -zkAddress localhost:2181 \
    -serverPort 8098 \
    -serverAdminPort 8097 \
    -dataDir "${DATA_DIR}/server" \
    -segmentDir "${DATA_DIR}/server/segments" &
echo $! > "${PID_DIR}/server.pid"

echo "Waiting for Broker to be ready..."
for i in $(seq 1 60); do
    if curl -sf "http://localhost:8099/health" | grep -q "OK"; then
        echo "Broker is ready"
        break
    fi
    echo "  waiting... ($i/60)"
    sleep 3
done

echo "Pinot cluster started."
