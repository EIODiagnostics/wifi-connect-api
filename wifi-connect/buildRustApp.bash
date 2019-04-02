#!/bin/bash

source $HOME/.cargo/env
cargo build --release --quiet
\rm -rf target
ls
