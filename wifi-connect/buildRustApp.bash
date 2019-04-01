#!/bin/bash

source $HOME/.cargo/env
cargo build --release
\rm -rf target
