#!/bin/sh

[ $(dirname $0) = "." ] && cd ../
. ./config.sh

cd $REPO || fatal

jmake clean

$CONFIGURECMD

jmake "$@"
