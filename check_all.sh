#!/bin/sh -x

. ./config.sh

rm -f $0.error.log
set_error()
{
    echo "$*" >>$0.error.log
}

# build and check with all engines
mkdir -p output || fatal
for EN in $ENGINES ; do
    engines/$EN.sh 2>output/$EN.err >output/$EN.log || set_error $EN
done

mkdir -p state || fatal
for i in output/*.err ; do
    EN=$(basename $i)
    cat $i | ./helpers/log_distinct_filter.sh >state/$EN
done

./analyze_log.sh || fatal

tail -n 10 output/scan-build.* | grep "to examine bug reports" && set_error scan-build-found-bug

if [ $(ls -1 $AUTHORSDIR | wc -l) != 0 ] ; then
    set_error new-warnings
fi

echo
if [ -n "$(cat $0.error.log)" ] ; then
    echo "ERROR during compiling with $(cat $0.error.log)"
    exit 1
fi

echo "DONE"
exit 0
