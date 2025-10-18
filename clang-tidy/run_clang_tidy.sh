#!/bin/bash

ANALYSIS_ROOT=$(realpath "$(dirname "$0")/..")

# Putanja do submodule projekta koji se analizira
PROJECT_ROOT="$ANALYSIS_ROOT/13-Git-stat"

# Folder gde cuvamo rezultate
OUTPUT_DIR="$ANALYSIS_ROOT/clang-tidy"
mkdir -p "$OUTPUT_DIR"

BUILD_DIR="$PROJECT_ROOT/build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"


cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..

# Find source and header files, skip Qt-generated ones
SOURCES=$(find "$PROJECT_ROOT"/src "$PROJECT_ROOT"/include \
    -type f \( -name "*.cpp" -o -name "*.h" \) \
    ! -path "$PROJECT_ROOT/src/gui/*" \
    ! -name "moc_*" ! -name "ui_*" ! -name "qrc_*")

# Opcija fix
FIX_OPTION=""
if [ "$1" == "fix=true" ]; then
    FIX_OPTION="--fix"
    echo "Clang-Tidy će pokušati automatski da ispravi kod."
fi

for file in $SOURCES; do
    clang-tidy \
        "$file" \
        -p="$BUILD_DIR" \
        --checks='
            clang-analyzer-*,
            readability-*,
            modernize-use-auto,
            modernize-use-nullptr,
            modernize-use-noexcept,
            modernize-use-emplace,
            modernize-use-emplace-back,
            modernize-loop-convert,
            modernize-use-using,
            -readability-magic-numbers,
            -cppcoreguidelines-avoid-magic-numbers,
            -readability-identifier-length
        ' \
        --header-filter="$PROJECT_ROOT/include/.*|$BUILD_DIR/ui_.*" \
        $FIX_OPTION \
        >> "$OUTPUT_DIR/clang_tidy_results.txt" || true
done
