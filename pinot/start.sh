#!/bin/bash

PINOT_VERSION="1.5.0"
PINOT_HOME="apache-pinot-${PINOT_VERSION}-bin"
PINOT_BIN="${PINOT_HOME}/bin/pinot-admin.sh"

echo "Starting Zookeeper"
JAVA_OPTS="-Xms2g -Xmx2g" ${PINOT_BIN} StartZookeeper -zkPort 2181 &
sleep 5

echo "Starting Controller"
JAVA_OPTS="-Xms2g -Xmx2g" ${PINOT_BIN} StartController \
    -zkAddress localhost:2181 \
    -controllerPort 9000 \
    -dataDir ./data/controller &
sleep 10

echo "Starting Broker"
JAVA_OPTS="-Xms4g -Xmx4g" ${PINOT_BIN} StartBroker \
    -zkAddress localhost:2181 \
    -brokerPort 8099 &
sleep 10

echo "Starting Server"
JAVA_OPTS="-Xms48g -Xmx48g -XX:MaxDirectMemorySize=48g" ${PINOT_BIN} StartServer \
    -zkAddress localhost:2181 \
    -serverPort 8098 \
    -serverAdminPort 8097 \
    -dataDir ./data/server \
    -segmentDir ./data/server/segments &
sleep 20

echo "Pinot cluster started."
