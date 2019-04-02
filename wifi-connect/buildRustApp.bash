#!/bin/bash

curl https://sh.rustup.rs -sSf > rustup-init 
chmod +x rustup-init
./rustup-init -y

source $HOME/.cargo/env
cargo build --release > /dev/null 2>&1
\rm -rf target
ls
