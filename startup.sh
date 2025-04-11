#!/usr/bin/env bash

set -x

git config --global user.name "git"
git config --global user.password "${GITHUB_TOKEN}"

git remote add gh https://git:${GITHUB_TOKEN}@github.com/thomasmburke/gorelease-testing.git

git fetch --tags gh
git pull gh main

# Get all tag names, sorted newest first
all_tags_sorted_newest_first=$(git ls-remote --tags --sort=-committerdate gh \
  | cut -f2 \
  | grep 'refs/tags/v' \
  | tr -d '^{}' \
  | uniq \
  | sed 's;refs/tags/;;')

# Get the absolute latest tag (the first one in the sorted list)
GORELEASER_CURRENT_TAG=$(echo "$all_tags_sorted_newest_first" | head -n 1)

# Filter out RC tags to get only non -rc tags
stable_tags_sorted_newest_first=$(echo "$all_tags_sorted_newest_first" | grep -v -- '-rc')

latest_stable_tag=$(echo "$stable_tags_sorted_newest_first" | head -n 1)

# Get the second latest stable tag (previous stable tag)
# Use sed -n '2p' to get the second line only. Handles cases with 0 or 1 non-RC tag gracefully (outputs nothing).
previous_stable_tag=$(echo "$stable_tags_sorted_newest_first" | sed -n '2p')

# --- Determine PREVIOUS tag ---

GORELEASER_PREVIOUS_TAG="" 

# Check if the latest tag is an RC tag
if [[ "$GORELEASER_CURRENT_TAG" == *-rc* ]]; then
  # Latest is an RC, so the previous tag should be the latest stable release
  GORELEASER_PREVIOUS_TAG="$latest_stable_tag"
else
  # Latest is a stable release, so the previous tag should be the previous stable release
  GORELEASER_PREVIOUS_TAG="$previous_stable_tag"
fi

echo "export GORELEASER_CURRENT_TAG=$GORELEASER_CURRENT_TAG" >> /github_assets/release_env
echo "export GORELEASER_PREVIOUS_TAG=$GORELEASER_PREVIOUS_TAG" >> /github_assets/release_env

cat -n /github_assets/release_env