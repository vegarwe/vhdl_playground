#!/bin/bash

set -e

function clean {
(
    rm -rf build
)
}

function compile {
(
    mkdir -p build
    cd build
    ghdl -a ../adder.vhdl
    ghdl -a ../adder_tb.vhdl
)
}

function run {
(
    cd build
    ghdl -e adder_tb
    ghdl -r adder_tb
)
}

function wave {
(
    cd build
    ghdl -r adder_tb --vcd=adder.vcd
    gtkwave adder.vcd
)
}

clean
compile
run
#wave
