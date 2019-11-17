
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

ENGINES="gcc-build cppcheck clang-build scan-build"

CONFIGURECMD="./configure --without-mingw"

export CCACHE_SLOPPINESS=pch_defines,time_macros
