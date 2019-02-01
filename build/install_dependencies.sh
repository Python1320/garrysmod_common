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

if [ ! -f "$PREMAKE5" ]; then
	PREMAKE_DIRECTORY="$DEPENDENCIES/$PROJECT_OS/premake-core"
	PREMAKE_TAR_PATH = "$PREMAKE_DIRECTORY/premake-core.tar.gz"
	create_directory_forcefully "$PREMAKE_DIRECTORY"
	curl -s "https://github.com/premake/premake-core/releases/download/v5.0.0-alpha13/premake-5.0.0-alpha13-linux.tar.gz" -o "$PREMAKE_TAR_PATH"
	tar -xf "$PREMAKE_TAR_PATH" -C "$PREMAKE_DIRECTORY"
	rm -f "$PREMAKE_TAR_PATH"
fi
