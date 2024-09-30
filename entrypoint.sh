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

GIT_PATH="${GITHUB_WORKSPACE:?}/$INPUT_PATH"

remote_branch_exists() {
  branch=$1
  if [ "$(git branch --list --remote origin/$branch)" = "" ]; then
    return 0
  else
    return 1
  fi
}

##
# The arguments to pass to `git checkout` to checkout the ref
#
# The argument is the ref to checkout, and may be a branch, tag, or commit.
# This typically comes from $GITHUB_REF, but can be specified as an input.
#
# Outputs a string of arguments to pass to `git checkout`.
#
# @param $1 The ref to checkout.
#
checkout_args() {
  ref=$1

  case $ref in
    refs/heads/*)
      # remote branch
      branch=$(echo "$ref" | sed 's|refs/heads/||')
      echo "-B $branch refs/remotes/origin/$branch"
      ;;
    refs/pull/*)
      # pull request
      pr_number=$(echo "$ref" | sed 's|refs/pull/||')
      echo "refs/remotes/pull/$pr_number"
      ;;
    refs/tags/*)
      # qualified ref
      echo "$ref"
      ;;
    refs/*)
      echo "$ref"
      ;;
    *)
      # unqualified ref

      if remote_branch_exists "$ref"; then
        # remote branch
        echo "-B $ref refs/remotes/origin/$ref"
      else
        # must be a tag
        echo "refs/tags/$ref"
      fi
      ;;
  esac

}

REF=${INPUT_REF:-$GITHUB_REF}

#rm -rf $GIT_PATH
git config --global --add safe.directory "${GITHUB_WORKSPACE:?}"
git config --list --show-origin

mkdir -p $GIT_PATH
git -C $GIT_PATH init "$GITHUB_WORKSPACE/$INPUT_PATH"
git -C $GIT_PATH remote add origin https://github.com/$INPUT_REPOSITORY
git -C $GIT_PATH fetch --depth=1 origin $REF

# shellcheck disable=SC2046
git -C $GIT_PATH checkout --force $(checkout_args $REF)

echo "::set-output name=ref::$REF"

COMMIT=$(git log -1 --format='%H')
echo "::set-output name=commit::$COMMIT"
