#!/bin/bash
ANALYSIS_ROOT=$(realpath "$(dirname "$0")/..")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$ANALYSIS_ROOT/13-Git-stat"
DOXYFILE="$ANALYSIS_ROOT/doxygen/Doxyfile"

# Run Doxygen
echo "Pokretanje Doxygen-a..."
cd "$PROJECT_ROOT"

doxygen "$DOXYFILE"
