#!/bin/bash

# Not my own work. Credit to original author
# Modified for multi-monitor support with shared master process

#----- Optimized bars animation without much CPU usage increase --------
bar="▁▂▃▄▅▆▇█"
dict="s/;//g"

# Calculate the length of the bar outside the loop
bar_length=${#bar}

# Create dictionary to replace char with bar
for ((i = 0; i < bar_length; i++)); do
    dict+=";s/$i/${bar:$i:1}/g"
done

# Shared files for all monitors
config_file="/tmp/bar_cava_config"
cache_file="/tmp/cava_cache"
master_pid_file="/tmp/cava_master.pid"

# Create cava config
cat >"$config_file" <<EOF
[general]
# Older systems show significant CPU use with default framerate
# Setting maximum framerate to 30  
# You can increase the value if you wish
framerate = 60
bars = 14

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

# Function to start master process
start_master() {
    # Start master cava process in background
    cava -p "$config_file" | sed -u "$dict" > "$cache_file" &
    local pid=$!
    echo $pid > "$master_pid_file"
    
    # Clean up function
    cleanup() {
        if [ -f "$master_pid_file" ]; then
            local master_pid=$(cat "$master_pid_file")
            kill $master_pid 2>/dev/null
            rm -f "$master_pid_file"
        fi
        rm -f "$cache_file"
    }
    
    # Set up trap for cleanup
    trap cleanup EXIT
    
    # Wait a moment for cache to be populated
    sleep 0.5
}

# Check if master process is running
if [ -f "$master_pid_file" ]; then
    master_pid=$(cat "$master_pid_file")
    if ! kill -0 "$master_pid" 2>/dev/null; then
        # Master process is dead, start new one
        rm -f "$master_pid_file" "$cache_file"
        start_master
    fi
else
    # No master process, start one
    start_master
fi

# Read from cache file and output to waybar
# This ensures all monitors show the same cava visualization
tail -f "$cache_file" 2>/dev/null || echo "▁▂▃▄▅▆▇█"
