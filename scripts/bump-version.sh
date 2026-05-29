#!/bin/bash
# Bump pubspec.yaml version, commit, and create a git tag.
# Usage: bash scripts/bump-version.sh 1.2.0

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <version> (e.g. 1.2.0)"
  exit 1
fi

VERSION="$1"
PUBSPEC="pubspec.yaml"

CURRENT=$(grep "^version:" $PUBSPEC | sed 's/version: //')
BUILD_NUM=$(echo "$CURRENT" | cut -d'+' -f2)
NEW_BUILD=$((BUILD_NUM + 1))
NEW_VERSION="${VERSION}+${NEW_BUILD}"

sed -i "s/^version: .*/version: ${NEW_VERSION}/" $PUBSPEC

echo "Version bumped: $CURRENT → $NEW_VERSION"

git add $PUBSPEC
git commit -m "Bump version to $NEW_VERSION"
git tag -a "v${VERSION}" -m "Release v${VERSION}"

echo ""
echo "Done. To trigger CI builds:"
echo "  git push && git push --tags"
