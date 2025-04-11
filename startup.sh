#!/usr/bin/env bash

set -x

git config --global user.name "git"
git config --global user.password "${GITHUB_TOKEN}"

git remote add gh https://git:${GITHUB_TOKEN}@github.com/thomasmburke/gorelease-testing.git

git fetch --tags gh
git pull gh main

git ls-remote --tags gh \
| cut -f2 \
| grep 'refs/tags/release/v' \
| tr -d '^{}' \
| sort \
| uniq \
| grep --invert-match '\-RC' \
| tail -2 \
| perl -p -e 's;refs/tags/(.*);$1;' \
> /tmp/release_tags.txt

GORELEASER_CURRENT_TAG=$(tail -1 /tmp/release_tags.txt)
GORELEASER_PREVIOUS_TAG=$(head -1 /tmp/release_tags.txt)

echo "export GORELEASER_CURRENT_TAG=$GORELEASER_CURRENT_TAG" >> /tmp/release_env
echo "export GORELEASER_PREVIOUS_TAG=$GORELEASER_PREVIOUS_TAG" >> /tmp/release_env

cat -n /tmp/release_env