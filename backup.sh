#!/usr/bin/bash

BACKUPS="$HOME/backups"
LUANTI_DIR="$HOME/luanti"
MAX_BACKUPS=7
mkdir -p "$BACKUPS"

# Step 1: stop running server

server_pid=$(pgrep -f "start.sh")
if [[ -n "$server_pid" ]]; then
    kill -SIGINT $server_pid # kills server with SIGINT, needed for correct turning off
    while ps -p "$server_pid" > /dev/null; do
        sleep 1
    done
fi

# Step 2: rotation

rm -f "$BACKUPS/luanti.tar.$MAX_BACKUPS.gz" # remove the oldest backup

for i in $(seq $((MAX_BACKUPS-1)) -1 1); do # move from maximum number to lower to avoid collisions
    if [ -f "$BACKUPS/luanti.tar.$i.gz" ]; then
        mv "$BACKUPS/luanti.tar.$i.gz" "$BACKUPS/luanti.tar.$((i+1)).gz"
    fi
done
if [ -f "$BACKUPS/luanti.tar.gz" ]; then
    mv "$BACKUPS/luanti.tar.gz" "$BACKUPS/luanti.tar.1.gz"
fi

# Step 3: create backup

tar -czf "$BACKUPS/luanti.tar.gz" -C "$LUANTI_DIR" worlds/ server.log

# Step 4: run the server again
nohup "$LUANTI_DIR/start.sh" > /dev/null 2>&1 &
