#!/bin/sh

. ./config.sh

rm -rf $AUTHORSDIR
mkdir -p $AUTHORSDIR


print_warning()
{
    echo
    echo "***"

    for engine in $ENGINES ; do
	ERRFILE=output/$engine.err
        # we found our warning in some file
        if grep -q "$FILE.*:$LINE" $ERRFILE ; then
        	echo "Detected by $engine checker. The warning is introduced in $COMMIT ($COMMITDATE), file $NORMFILE, line $LINE"
        	echo "$COMMENT"
        	echo
        	# show only one line for cppcheck output
        	if [ "$ENGINE" = "cppcheck" ] ; then
        		# -m1 means return the first match
        		grep -m1 "$FILE.*:$LINE" $ERRFILE
        	else
        		grep -m1 -C 7 "$FILE.*:$LINE" $ERRFILE
        	fi
        	break
        fi
    done

}

get_commit_info()
{
    if [ -z "$LINE" ] ; then
        echo "Empty line for $NORMFILE" >&2
        return 1
    fi

    if grep -q $NORMFILE ./ignore.list.txt ; then
        echo "Ignore $NORMFILE (see ./ignore.list.txt)"
        return 1
    fi

    ( cd $REPO && git blame --line-porcelain -L$LINE,$LINE $NORMFILE) >$0.tmp_porc
    COMMIT=$(cat $0.tmp_porc | head -1 | cut -d" " -f1)
    COMMITDATE=$( cd $REPO && git show -s --format=%ci $COMMIT)
    AUTHOR=$(cat $0.tmp_porc | grep "^author " | cut -d" " -f2)
    AUTHORMAIL=$(cat $0.tmp_porc | grep "^author-mail " | cut -d" " -f2 | sed -e "s|[<>]||g")

    #echo "COMMIT: $COMMIT AUTHOR: $AUTHOR AUTHORMAIL: $AUTHORMAIL FILE: $NORMFILE LINE: $LINE"
}

norm_warnings()
{
PREVFILE=
PREVLINE=
PREVCOMMENT=
PREVNORMFILE=
while read FILE LINE COMMENT; do

    # hack: search for name only
    # TODO: нужно максимальное совпадение
    NORMFILE=$(grep "/$(basename $FILE)$" $0.files | head -n1)
    if [ -z "$NORMFILE" ] ; then
        echo "Can't find file $FILE" >&2
        continue
    fi

    if [ "$NORMFILE" = "$PREVNORMFILE" ] && [ "$LINE" = "$PREVLINE" ] ; then
        PREVCOMMENT="$PREVCOMMENT ($COMMENT)"
        continue
    else
        echo "$PREVNORMFILE $PREVFILE $PREVLINE $PREVCOMMENT"
        PREVFILE=$FILE
        PREVLINE=$LINE
        PREVCOMMENT=$COMMENT
        PREVNORMFILE=$NORMFILE
    fi

    #echo "$NORMFILE $FILE $LINE $COMMENT"
done
echo "$PREVNORMFILE $PREVFILE $PREVLINE $PREVCOMMENT"
}

parse_input()
{
while read NORMFILE FILE LINE COMMENT; do

    get_commit_info || continue

    if [ -z "$AUTHORMAIL" ] ; then
        echo "Can't parse $FILE $LINE info" >&2
        continue
    fi

    if [ ! -s "$AUTHORSDIR/$AUTHORMAIL" ] ; then
        date >>$AUTHORSDIR/$AUTHORMAIL || exit
    fi

    #MAILTO=lav@etersoft
    #mutt -S ""

    print_warning >> $AUTHORSDIR/$AUTHORMAIL
done
}

NUM="[0-9][0-9]*"
( cd $REPO && find -type f ) >$0.files

# TODO: we failed with various warning descriptions
echo "Get all unique warnings..."
rm -f $0.warnings
for engine in $ENGINES ; do
	echo "    * $engine ..."
	cat output/$engine.err | egrep "^[^ ]*\.(c|cc|cpp|h):$NUM[: ]" | sed -e "s!\(.c\|.cc\|.cpp\|.h\):\($NUM\): !\1 \2 !g" -e "s!\(.c\|-cc\|.cpp\|.h\):\($NUM\):$NUM: !\1 \2 !g" | sort -u >> $0.warnings
done
cat $0.warnings | norm_warnings | tee $0.normwarnings | parse_input
#rm -f $0.warnings
