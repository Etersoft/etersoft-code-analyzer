#!/bin/sh

cat log_distinct_filter.list | ./log_distinct_filter.sh | tee $0.output
echo
diff -u log_distinct_filter.list $0.output

echo "---"
NUM="[0-9][0-9]*"
cat log_distinct_filter.list | egrep "^[^ ]*\.(cpp|h):$NUM[: ]" | sed -e "s!\(.cpp\|.h\):\($NUM\)[: ].*!\1 \2!g" | tee $0.fe

