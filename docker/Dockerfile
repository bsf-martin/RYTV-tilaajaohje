# Build image for the RYTV tilaajaohje (HTML page and PDF).
# Everything the build needs and nothing else: Pandoc, XeLaTeX/LuaLaTeX with Finnish
# hyphenation, and git (the version string is taken from the repository).
# The brand fonts are NOT in the image: they live in the repository (templates/fonts-pdf).
#
# Bump PANDOC_VERSION to upgrade Pandoc, then publish the image (see
# .github/workflows/build-image.yml) and update the tag used in build-docs.yml.
FROM debian:bookworm-slim

ARG PANDOC_VERSION=3.14
ARG TARGETARCH

LABEL org.opencontainers.image.source="https://github.com/bsf-martin/RYTV-tilaajaohje" \
      org.opencontainers.image.description="Pandoc ${PANDOC_VERSION} + XeLaTeX build image for the RYTV tilaajaohje" \
      org.opencontainers.image.licenses="CC-BY-4.0"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git \
      texlive-xetex texlive-luatex texlive-latex-recommended texlive-latex-extra \
      texlive-fonts-recommended texlive-lang-european lmodern \
 && curl -fsSL -o /tmp/pandoc.deb \
      "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-${TARGETARCH}.deb" \
 && apt-get install -y /tmp/pandoc.deb \
 && rm -rf /tmp/pandoc.deb /var/lib/apt/lists/* \
 && git config --system --add safe.directory '*'

WORKDIR /git
