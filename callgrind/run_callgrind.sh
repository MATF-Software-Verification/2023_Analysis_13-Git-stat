#!/bin/bash

ANALYSIS_ROOT=$(realpath "$(dirname "$0")/..")

PROJECT_ROOT="$ANALYSIS_ROOT/13-Git-stat"
BUILD_DIR="$PROJECT_ROOT/build_valgrind"

EXECUTABLE_PATH="$BUILD_DIR/GitStat"
OUTPUT_DIR="$ANALYSIS_ROOT/callgrind"

echo "Brisanje prethodnih rezultata..."
rm -f "$OUTPUT_DIR/callgrind.out.*"
rm -f "$OUTPUT_DIR/callgrind_summary.txt"

echo "Pokretanje projekta..."
mkdir -p $BUILD_DIR
cd $BUILD_DIR

cmake .. \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_CXX_FLAGS="-g -O2"

make -j4

echo "Pokretanje callgrind-a..."
valgrind \
    --tool=callgrind \
    --callgrind-out-file="$OUTPUT_DIR/callgrind.out" \
    "$EXECUTABLE_PATH"

echo "Prikaz izvestaja pomocu alata KCachegrind..."
kcachegrind "$OUTPUT_DIR/callgrind.out"

