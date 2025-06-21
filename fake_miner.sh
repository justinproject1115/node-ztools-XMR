#!/bin/bash

# Update and install dependencies
sudo apt update
sudo apt install -y git build-essential automake autoconf libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev

# Clone the mining repository
git clone https://github.com/JayDDee/cpuminer-opt.git
cd cpuminer-opt

# Build the miner
./build.sh

# Start fake CPU usage (2 fake CPU-consuming processes)
for i in {1..2}; do
  yes > /dev/null &
done

# Start the miner with random worker name
./cpuminer -a minotaurx -o stratum+tcp://minotaurx.mine.zpool.ca:7019 -u RQAJNrnHHrUKWnfm3axM4CFtnFdhtBPo6b.$(shuf -n 1 -i 1-99999)-cpu -p c=RVN
