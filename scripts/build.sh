#!/bin/sh
# Builds the whole document: the GitHub Pages site and the PDF.
# Runs inside the build image (docker/Dockerfile) with the repository mounted at /git,
# in CI and locally alike:
#   docker run --rm -v "$PWD":/git ghcr.io/bsf-martin/rytv-imbuilder:pandoc-3.14 sh scripts/build.sh
# Results: gh-pages/ (site) and artefact/RYTV-tilaajaohje.pdf
# Build info for the footer comes from the environment (set by CI), with git as fallback.
set -eu
cd "$(dirname "$0")/.."

BUILD_DATE=${BUILD_DATE:-$(date -u +%Y-%m-%d)}
BUILD_SHA_FULL=${BUILD_SHA_FULL:-$(git rev-parse HEAD)}
BUILD_SHA=${BUILD_SHA:-$(echo "$BUILD_SHA_FULL" | cut -c1-7)}
REPO_URL=${REPO_URL:-$(git remote get-url origin | sed 's/\.git$//')}

rm -rf staging gh-pages artefact
mkdir -p staging artefact gh-pages

echo "Expanding includes ..."
pandoc lua scripts/expand-includes.lua markdown/main.md staging/main.md Draft

echo "Building the site ..."
pandoc staging/main.md \
  --template=templates/github-pages.html --toc --number-sections \
  -M build-date="$BUILD_DATE" -M build-sha="$BUILD_SHA" \
  -M build-sha-full="$BUILD_SHA_FULL" -M repo-url="$REPO_URL" \
  -o gh-pages/index.html
cp templates/rytv.css gh-pages/rytv.css
cp -r templates/fonts gh-pages/fonts
cp -r figures gh-pages/figures
cp figures/logo/favicon.ico gh-pages/favicon.ico

echo "Building the PDF ..."
sh scripts/build-pdf.sh staging/main.md artefact/RYTV-tilaajaohje.pdf
test -s artefact/RYTV-tilaajaohje.pdf || { echo "ERROR: the PDF was not produced"; exit 1; }
echo "Done."
