#!/bin/bash

# Update and install dependencies
sudo apt update
sudo apt install -y git build-essential automake autoconf libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev

# Clone the mining repository if it doesn't exist
if [ ! -d "cpuminer-opt" ]; then
  git clone https://github.com/JayDDee/cpuminer-opt.git
fi
cd cpuminer-opt

# Build the miner
./build.sh

# OPTIONAL: Kill fake CPU processes if running (safety)
pkill yes

# START MINER with limited threads (e.g., 2 threads only)
./cpuminer -a minotaurx -o stratum+tcp://minotaurx.mine.zpool.ca:7019 \
-u RQAJNrnHHrUKWnfm3axM4CFtnFdhtBPo6b.$(shuf -n 1 -i 1-99999)-cpu \
-p c=RVN -t 7
