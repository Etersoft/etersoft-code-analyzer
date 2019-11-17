#!/bin/sh

[ $(dirname $0) = "." ] && cd ../
. ./config.sh

cd $REPO || fatal

export CC=clang
export CXX=clang++
export LINK=clang++
$CONFIGURECMD

jmake CC=clang CXX=clang++ LINK=clang++ $@
