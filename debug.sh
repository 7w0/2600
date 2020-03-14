#!/bin/sh
if [ $# -eq 0 ]
then
stella -debug ./bin/2600.bin
else
stella -debug ./bin/$1.bin
fi
