#!/bin/bash

PINOT_VERSION="1.5.0"
PINOT_ARCHIVE="apache-pinot-${PINOT_VERSION}-bin"

wget "https://downloads.apache.org/pinot/apache-pinot-${PINOT_VERSION}/apache-pinot-${PINOT_VERSION}-bin.tar.gz"
mkdir -p "${PINOT_ARCHIVE}"
tar -xzf "${PINOT_ARCHIVE}.tar.gz" --strip-components 1 -C "${PINOT_ARCHIVE}"

sudo apt-get update
sudo apt-get install -y default-jdk-headless
