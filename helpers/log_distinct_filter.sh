#!/bin/sh

NUM="[0-9][0-9]*"
# drop out line and column lines
sed -e "s!\(.cpp\|.h\):$NUM:$NUM\([,:]\)!\1\2!g" -e "s!\(.cpp\|.h\):$NUM\([,:]\)!\1\2!g" | egrep -v "^(real|user|sys) [0-9]"

