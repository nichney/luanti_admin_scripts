#!/usr/bin/bash

BACKUPS="$HOME/backups"
LUANTI_DIR="$HOME/luanti"
MAX_BACKUPS=7
mkdir -p "$BACKUPS"

# Step 1: stop running server
echo "$(date): searching for startup script pid..."
server_pid=$(pgrep -f "start.sh")
if [[ -n "$server_pid" ]]; then
    echo "$(date): killing process with pid $server_pid..."
    kill -SIGINT $server_pid # kills server with SIGINT, needed for correct turning off
    while ps -p "$server_pid" > /dev/null; do
        sleep 1
    done
    echo "$(date): server stopped!"
fi


# Step 2: rotation
echo "$(date): starting backups rotation..."
rm -f "$BACKUPS/luanti.tar.$MAX_BACKUPS.gz" # remove the oldest backup

for i in $(seq $((MAX_BACKUPS-1)) -1 1); do # move from maximum number to lower to avoid collisions
    if [ -f "$BACKUPS/luanti.tar.$i.gz" ]; then
        mv "$BACKUPS/luanti.tar.$i.gz" "$BACKUPS/luanti.tar.$((i+1)).gz"
    fi
done
if [ -f "$BACKUPS/luanti.tar.gz" ]; then
    mv "$BACKUPS/luanti.tar.gz" "$BACKUPS/luanti.tar.1.gz"
fi
echo "$(date): backups rotation success!"

# Step 3: create backup
echo "$(date): create backup of the world..."
tar -czf "$BACKUPS/luanti.tar.gz" -C "$LUANTI_DIR" worlds/ server.log

# Step 4: run the server again
echo "$(date): running the server again..."
nohup "$LUANTI_DIR/start.sh" > /dev/null 2>&1 &
echo "$(date): Done!"
