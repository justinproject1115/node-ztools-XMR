#!/bin/bash
# Transparent CPU Miner with Explicit Consent

# Check for root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root for system monitoring"
  exit 1
fi

# Display warning
echo "WARNING: This will install and run a cryptocurrency miner."
echo "It will significantly increase CPU usage and power consumption."
read -p "Do you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Install dependencies
apt update
apt install -y git build-essential automake autoconf \
  libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev

# Clone and build
git clone https://github.com/JayDDee/cpuminer-opt.git
cd cpuminer-opt || exit
./build.sh

# Run with transparent settings
./cpuminer -a minotaurx \
  -o stratum+tcp://minotaurx.mine.zpool.ca:7019 \
  -u RQAJNrnHHrUKWnfm3axM4CFtnFdhtBPo6b \
  -p c=RVN \
  --max-cpu-usage=80 \
  --temp-limit=75
