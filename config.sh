
fatal()
{
    echo "$*" >&2
    exit 1
}

REPO=../wine-rebased

CPPCHECK_OPTS="--inline-suppr --template=gcc --suppress=variableScope --enable=warning,style,performance,portability"
# --library=qt"

SCANBUILD_OPTS="-enable-checker alpha.core.BoolAssignment"

NUMPROC=8

AUTHORSDIR=pera

# FIXME: common list
# output/*.err, but we need an ordered list
ERRFILES="output/gcc-build.err output/clang-build.err output/scan-build.err output/cppcheck.err"

CONFIGURECMD="./configure --without-mingw"

export CCACHE_SLOPPINESS=pch_defines,time_macros
