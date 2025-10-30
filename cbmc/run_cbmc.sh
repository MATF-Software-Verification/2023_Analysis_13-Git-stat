#!/bin/bash

ANALYSIS_ROOT=$(realpath "$(dirname "$0")/..")
PROJECT_ROOT="$ANALYSIS_ROOT/13-Git-stat"
OUTPUT_DIR="$ANALYSIS_ROOT/cbmc"

cbmc $PROJECT_ROOT/tests/cbmc/processing_commit.cpp --unwind 5 --bounds-check --pointer-check --trace > $OUTPUT_DIR/output.txt