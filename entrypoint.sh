#!/bin/sh

set -ex

printenv

# If the inputs are not set, error
if [ -z "$INPUT_REPOSITORY" ]; then
  echo "Set the repository input"
  exit 1
fi

# If the inputs are not set, error
if [ -z "$INPUT_PATH" ]; then
  echo "Set the path input"
  exit 1
fi

# If the inputs are not set, error
if [ -z "$INPUT_TOKEN" ]; then
  echo "Set the token input"
  exit 1
fi

REF=${INPUT_REF:-$GITHUB_REF}

#rm -rf "${GITHUB_WORKSPACE:?}/$INPUT_PATH"
git config --global --add safe.directory "${GITHUB_WORKSPACE:?}"
git config --list --show-origin

mkdir -p "${GITHUB_WORKSPACE:?}/$INPUT_PATH"
git -C "${GITHUB_WORKSPACE:?}/$INPUT_PATH" init "$GITHUB_WORKSPACE/$INPUT_PATH"
git -C "${GITHUB_WORKSPACE:?}/$INPUT_PATH" remote add origin https://github.com/$INPUT_REPOSITORY
git -C "${GITHUB_WORKSPACE:?}/$INPUT_PATH" fetch --depth=1 origin $REF
git -C "${GITHUB_WORKSPACE:?}/$INPUT_PATH" checkout --force $REF

echo "::set-output name=ref::$REF"

COMMIT=$(git log -1 --format='%H')
echo "::set-output name=commit::$COMMIT"
