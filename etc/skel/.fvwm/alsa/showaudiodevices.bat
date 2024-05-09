#! /bin/bash

echo ""
echo "__________ PLAYERS __________"
echo ""
aplay -L 

echo ""
echo "__________ LISTENERS __________"
echo ""
arecord -L 

echo ""
echo "__________ MEMORY ADDRESSES __________"
echo ""
dmesg | grep snd

