#!/bin/bash

# Exit if any command fails and if any unset variable is used
set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE:-$0}" )" && pwd )"

. "${DIR}/install_dependencies.sh"

pushd "$REPOSITORY_DIR/projects"
"$PREMAKE5" "$COMPILER_PLATFORM"
popd

pushd "$REPOSITORY_DIR/projects/$PROJECT_OS/$COMPILER_PLATFORM"
make -j "$JOBS"
popd
