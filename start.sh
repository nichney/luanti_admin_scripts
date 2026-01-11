#!/usr/bin/bash

running=true

handle_exit() {
    echo "Stopping..."
    running=false
}

trap handle_exit SIGINT SIGTERM

echo "Server is running. To stop press Ctrl+C"

while $running
do
    ~/luanti/bin/luantiserver --logfile "$HOME/luanti/server.log"
    
    if ! $running; then
        break
    fi
    
    echo "Server crashed, run again in 2 seconds..."
    sleep 2
done

echo "Done."
