#!/bin/sh
if [ $# -eq 0 ]
then
stella ./bin/2600.bin
else
stella ./bin/$1.bin
fi
