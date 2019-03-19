#!/bin/bash

set -eux

ZIP_FILE=gh-pages.zip
REPOSITORY_NAME=isl-reseau-2018
REPOSITORY_OWNER=dduportal
REPOSITORY_URL="https://github.com/${REPOSITORY_OWNER}/${REPOSITORY_NAME}/archive/${ZIP_FILE}"
CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd -P)"
DOCS_DIR="${CURRENT_DIR}/../docs"

# Rebuild the docs directory which will be uploaded to gh-pages
rm -rf "${DOCS_DIR}"
if curl -sSLI --fail "${REPOSITORY_URL}"
then
    curl -sSLO "${REPOSITORY_URL}"
    unzip -o "./${ZIP_FILE}"
    mv ./${REPOSITORY_NAME}-${ZIP_FILE%%.*} "${DOCS_DIR}" # No ".zip" at the end
    rm -f "./${ZIP_FILE}"
else
    echo "== No gh-pages found, I assume this is the first time."
    mkdir -p "${DOCS_DIR}"
fi

# If a tag triggered the deploy, we deploy to a folder having the tag name
# otherwise we are on master and we deploy into latest
set +u
DEPLOY_DIR="${DOCS_DIR}/${TRAVIS_TAG}"
if [ -n "${TRAVIS_TAG}" ]; then
    # Generate QRCode and overwrite the default one
    make chmod
    make qrcode
fi
set -u

rsync -av ./dist/ "${DEPLOY_DIR}"
