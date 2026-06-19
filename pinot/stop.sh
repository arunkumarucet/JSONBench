#!/bin/bash

PID_DIR="$(pwd)/pids"

stop_pid() {
    local name=$1
    local pidfile="${PID_DIR}/${name}.pid"
    if [[ -f "$pidfile" ]]; then
        local pid=$(cat "$pidfile")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Stopping ${name} (pid $pid)"
            kill "$pid"
            # Wait up to 30s for graceful shutdown, then force kill
            for i in $(seq 1 30); do
                kill -0 "$pid" 2>/dev/null || break
                sleep 1
            done
            if kill -0 "$pid" 2>/dev/null; then
                echo "Force killing ${name} (pid $pid)"
                kill -9 "$pid"
            fi
        fi
        rm -f "$pidfile"
    fi
}

# Stop in reverse startup order
stop_pid server
stop_pid broker
stop_pid controller
stop_pid zookeeper

echo "Pinot stopped."
