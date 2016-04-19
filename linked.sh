#!/bin/bash

set -e

function clean {
    mkdir -p work
    rm   -rf work/*
    #ghdl --clean --workdir=work
}

function compile {
    mkdir -p work
    ghdl -c --workdir=work --std=02 --ieee=standard linked.vhdl linked_tb.vhdl -e linked_tb
}

function run {
    ghdl -r linked_tb
}

clean
compile
run
