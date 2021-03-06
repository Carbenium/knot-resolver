#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Create a develpoment tarball
set -o errexit -o nounset -o xtrace

cd "$(dirname ${0})/.."

# devel version
GIT_HASH=$(git rev-parse --short HEAD )
TIMESTAMP=$(date -u +'%s' 2>/dev/null)

# make sure we don't accidentally add / overwrite forgotten changes in git
(git diff-index --quiet HEAD && git diff-index --cached --quiet HEAD) || \
    (echo 'git index has uncommited changes!'; exit 1)

# modify and commit meson.build
sed -i "s/^\(\s*version\s*:\s*'\)\([^']\+\)\('.*\)/\1\2.$TIMESTAMP.$GIT_HASH\3/" meson.build

: changed version in meson.build, changes must be commited to git
git add meson.build
git commit -m 'DROP: devel version archive'

cleanup() {
    # undo commit
    git reset --hard HEAD^ >/dev/null
}
trap cleanup EXIT

# create tarball
rm -rf build_dist ||:
meson build_dist
ninja -C build_dist dist

# print path to generated tarball
set +o xtrace
find "${PWD}/build_dist/meson-dist/" -name "knot-resolver-*.tar.xz"
