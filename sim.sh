#!/bin/sh

echo "Analyzing source file"
ghdl -a ../src/$1.vhd

echo "Analyzing testbench"
ghdl -a ../tests/$1_tb.vhd

"Running simulation"
ghdl -r $1_tb --wave=$1_tb.ghw

"Opening gtkwave"
gtkwave $1_tb.ghw
