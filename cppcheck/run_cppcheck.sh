#!/usr/bin/bash

ANALYSIS_ROOT=$(realpath "$(dirname "$0")/..")
PROJECT_ROOT="$ANALYSIS_ROOT/13-Git-stat"
BUILD_DIR="$PROJECT_ROOT/build"
CPP_CHECK_DIR=$ANALYSIS_ROOT/cppcheck
HTMLREPORT_DIR=$CPP_CHECK_DIR/cppcheck_html
TXT_REPORT=$CPP_CHECK_DIR/cppcheck_results.txt
HTMLREPORT_SCRIPT=~/tools/cppcheck/htmlreport/cppcheck-htmlreport

# Kreiranje direktorijuma ako ne postoji
mkdir -p "$CPP_CHECK_DIR"
mkdir -p "$HTMLREPORT_DIR"

echo "Pokretanje Cppcheck analize..."

# Pokretanje Cppcheck i generisanje XML izveštaja
cppcheck --enable=all \
         --inconclusive \
         --std=c++17 \
         --suppress=missingIncludeSystem \
         -i $PROJECT_ROOT/tests \
         -i build \
         --xml --xml-version=2 \
         $PROJECT_ROOT 2> $CPP_CHECK_DIR/cppcheck_results.xml

if [ $? -ne 0 ]; then
    echo "Cppcheck analiza nije uspela."
    exit 1
fi

echo "Cppcheck analiza završena. XML izveštaj: $CPP_CHECK_DIR/cppcheck_results.xml"

# Generisanje TXT izveštaja
echo "Generisanje TXT izveštaja..."
cppcheck --enable=all \
         --inconclusive \
         --std=c++17 \
         --suppress=missingIncludeSystem \
         -i $PROJECT_ROOT/tests \
         -i build/ \
         $PROJECT_ROOT > $TXT_REPORT 2>&1

if [ $? -ne 0 ]; then
    echo "Greška pri generisanju TXT izveštaja."
    exit 1
fi

echo "TXT izveštaj generisan u: $TXT_REPORT"

# Generisanje HTML izveštaja iz XML-a
echo "Generisanje HTML izveštaja..."
python3 $HTMLREPORT_SCRIPT \
    --file=$CPP_CHECK_DIR/cppcheck_results.xml \
    --report-dir=$HTMLREPORT_DIR \
    --source-dir=$PROJECT_DIR/13-Git-stat

if [ $? -ne 0 ]; then
    echo "Greška pri generisanju HTML izveštaja."
    exit 1
fi

echo "HTML izveštaj generisan u: $HTMLREPORT_DIR"
echo "Otvaranje izveštaja:"
xdg-open $HTMLREPORT_DIR/index.html