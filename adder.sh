#!/bin/bash

set -e

function clean {
    mkdir -p work
    ghdl --clean --workdir=work
    #ghdl --remove --workdir=work
    #rm -rf work
}

function compile {
    mkdir -p work
    #ghdl -a --workdir=work --std=08 --ieee=standard adder.vhdl
    #ghdl -a --workdir=work --std=08 --ieee=standard adder_tb.vhdl
    #ghdl -e --workdir=work --std=08 --ieee=standard adder_tb
    ghdl -c --workdir=work --std=08 --ieee=standard -Posvvm *.vhdl -e adder_tb
}

function run {
    ghdl -r adder_tb
}

function wave {
    mkdir -p work
    ghdl -r adder_tb --vcd=work/adder.vcd
    gtkwave work/adder.vcd 2> /dev/null
}

function build_OSVVM {
    #ghdl -a --std=08 --work=ieee_proposed ../OS-VVM_2_3_1/vhdl_2002_versions/standard_additions_c.vhdl
    #ghdl -a --std=08 --work=ieee_proposed ../OS-VVM_2_3_1/vhdl_2002_versions/standard_textio_additions_c.vhdl

    mkdir -p osvvm
    ghdl -a --std=08 --work=osvvm --workdir=osvvm --ieee=standard OSVVM/NamePkg.vhd
    ghdl -a --std=08 --work=osvvm --workdir=osvvm --ieee=standard OSVVM/OsvvmGlobalPkg.vhd
    ghdl -a --std=08 --work=osvvm --workdir=osvvm --ieee=standard OSVVM/TranscriptPkg.vhd
    ghdl -a --std=08 --work=osvvm --workdir=osvvm --ieee=standard OSVVM/TextUtilPkg.vhd
    ghdl -a --std=08 --work=osvvm --workdir=osvvm --ieee=standard OSVVM/AlertLogPkg.vhd
    ghdl -a --std=08 --work=osvvm --workdir=osvvm --ieee=standard OSVVM/SortListPkg_int.vhd
    ghdl -a --std=08 --work=osvvm --workdir=osvvm --ieee=standard OSVVM/RandomBasePkg.vhd
    ghdl -a --std=08 --work=osvvm --workdir=osvvm --ieee=standard OSVVM/RandomPkg.vhd
    ghdl -a --std=08 --work=osvvm --workdir=osvvm --ieee=standard OSVVM/MessagePkg.vhd
    ghdl -a --std=08 --work=osvvm --workdir=osvvm --ieee=standard OSVVM/CoveragePkg.vhd
    ghdl -a --std=08 --work=osvvm --workdir=osvvm --ieee=standard OSVVM/MemoryPkg.vhd
    ghdl -a --std=08 --work=osvvm --workdir=osvvm --ieee=standard OSVVM/OsvvmContext.vhd
    ghdl -a --std=08 --work=osvvm --workdir=osvvm --ieee=standard OSVVM/TbUtilPkg.vhd

    #ghdl -a --std=08 --work=OSVVM --workdir=OSVVM --ieee=standard OSVVM/demo/AlertLog_Demo_Global.vhd
    #ghdl -a --std=08 --work=OSVVM --workdir=OSVVM --ieee=standard OSVVM/demo/AlertLog_Demo_Hierarchy.vhd
    #ghdl -a --std=08 --work=OSVVM --workdir=OSVVM --ieee=standard OSVVM/demo/Demo_Rand.vhd
    #hdl -e --std=08 --work=OSVVM --workdir=OSVVM --ieee=standard Demo_Rand
    #./Demo_rand



}

clean
build_OSVVM
compile
run
#wave
