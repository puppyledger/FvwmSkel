#! /bin/bash

tar -xvf termcap-1.3.1.tar.gz
cd termcap-1.3.1
./configure --enable-install-termcap
make
make install

