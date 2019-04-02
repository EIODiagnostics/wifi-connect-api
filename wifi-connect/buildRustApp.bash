#!/bin/bash

curl https://sh.rustup.rs -sSf > rustup-init.bash
chmod +x rustup-init.bash
./rustup-init.bash -y

source $HOME/.cargo/env
cargo build --release > /dev/null 2>&1
# cross cross-strip target/$TARGET/release/wifi-connect
