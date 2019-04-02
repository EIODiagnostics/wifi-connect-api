#!/bin/bash

source $HOME/.cargo/env
cargo build --release > /dev/null 2>&1
\rm -rf target
ls
