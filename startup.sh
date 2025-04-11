#!/usr/bin/env bash

set -x

git ls-remote --tags origin \
| cut -f2 \
| grep 'refs/tags/release/v' \
| tr -d '^{}' \
| sort \
| uniq \
| grep --invert-match '\-RC' \
| tail -2 \
| perl -p -e 's;refs/tags/(.*);$1;' \
> release_tags.txt

GORELEASER_CURRENT_TAG=$(tail -1 release_tags.txt)
GORELEASER_PREVIOUS_TAG=$(head -1 release_tags.txt)

echo "export GORELEASER_CURRENT_TAG=$GORELEASER_CURRENT_TAG" >> release_env
echo "export GORELEASER_PREVIOUS_TAG=$GORELEASER_PREVIOUS_TAG" >> release_env

cat -n release_env