#!/bin/bash
ANALYSIS_ROOT=$(realpath "$(dirname "$0")/..")

PROJECT_ROOT="$ANALYSIS_ROOT/13-Git-stat"
BUILD_DIR="$PROJECT_ROOT/build_valgrind"

EXECUTABLE_PATH="$BUILD_DIR/GitStat"
OUTPUT_DIR="$ANALYSIS_ROOT/memcheck"

echo "Brisanje prethodnih rezultata..."
rm -f "$OUTPUT_DIR/memcheck_*.log"

echo "Pokretanje projekta..."
mkdir -p $BUILD_DIR
cd $BUILD_DIR

cmake .. \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_CXX_FLAGS="-g -O1"

make

echo "Pokretanje memcheck-a..."
valgrind \
    --tool=memcheck \
    --leak-check=full \
    --show-leak-kinds=all \
    --track-origins=yes \
    --verbose \
    --log-file="$OUTPUT_DIR/memcheck_full.log" \
    --suppressions="$ANALYSIS_ROOT/memcheck/qt.supp" \
    "$EXECUTABLE_PATH"

