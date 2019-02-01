#!/bin/bash

# Exit if any command fails and if any unset variable is used
set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE:-$0}" )" && pwd )"

. "${DIR}/setup.sh"

# Checkout with the correct line endings on plain text files, depending on the host OS
git config --global core.autocrlf true >/dev/null 2>/dev/null

update_local_git_repository "$GARRYSMOD_COMMON" "$GARRYSMOD_COMMON_REPOSITORY" "improve-build-scripts"

if [ ! -z "${SOURCE_SDK+x}" ]; then
	update_local_git_repository "$SOURCE_SDK" "https://github.com/danielga/sourcesdk-minimal.git"
fi

$BUILD_PREMAKE5=$(update_local_git_repository "$DEPENDENCIES/premake-core" "https://github.com/premake/premake-core.git")

create_directory_forcefully "$DEPENDENCIES/$PROJECT_OS"

if [ $BUILD_PREMAKE5 -eq 1 ] ; then
	echo "premake-core needs building, bootstrapping"
	pushd "$DEPENDENCIES/premake-core"
	make -j "$JOBS" -f Bootstrap.mak "$TARGET_OS"
	popd
	create_directory_forcefully "$DEPENDENCIES/$PROJECT_OS/premake-core"
	cp "$DEPENDENCIES/premake-core/bin/release/$PREMAKE5_EXECUTABLE" "$"
fi
