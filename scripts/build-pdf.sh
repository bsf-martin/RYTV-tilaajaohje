#!/bin/sh
# Builds the PDF from the expanded Markdown with XeLaTeX and the RYTV template.
# Usage: sh scripts/build-pdf.sh <staging/main.md> <out.pdf>   (run from the repository root)
set -eu
in=$1
out=$2
assets="$(pwd)/"

pandoc "$in" -o "$out" \
  --from=markdown+escaped_line_breaks+hard_line_breaks \
  --pdf-engine=xelatex \
  --template=templates/pdf.latex \
  --number-sections --toc --toc-depth=2 \
  -V assets="$assets" -V toc-title=Sisällys \
  -V documentclass=scrartcl -V classoption=a4paper -V fontsize=11pt \
  -V geometry:left=22mm -V geometry:right=22mm -V geometry:top=28mm -V geometry:bottom=26mm \
  -V colorlinks=true -V linkcolor=rytvblue -V urlcolor=rytvblue -V toccolor=rytvnavy
