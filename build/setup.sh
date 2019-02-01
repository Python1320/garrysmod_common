#!/bin/bash

# Exit if any command fails and if any unset variable is used
set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE:-$0}" )" && pwd )"

export JOBS=$(getconf _NPROCESSORS_ONLN)

function validate_variable_or_set_default {
	NAME="$1"
	DEFAULT="$2"

	value="$DEFAULT"
	if [ "${!NAME}" ]; then
		value="${!NAME}"
	fi

	if [ -z "$value" ]; then
		if [ -z "$DEFAULT" ]; then
			exit 1
		fi

		export "$NAME"="$value"
	fi
}

function update_local_git_repository {
	$DIRECTORY="$1"
	$REPOSITORY="$2"
	$BRANCH="${3:-master}"

	$UPDATED=0
	if [ ! $(git -C "$DIRECTORY" rev-parse --is-inside-work-tree >/dev/null 2>/dev/null) ]; then
		rm -rf "$DIRECTORY"
		git clone --quiet --depth 1 --shallow-submodules --recursive "$REREPOSITORYPO" "$DIRECTORY"
		$UPDATED=1
	else
		pushd "$DIRECTORY"

		git fetch --quiet --all

		CURBRANCH=$(git symbolic-ref --quiet --short HEAD)
		if [ ! $BRANCH = $CURBRANCH ]; then
			git checkout --quiet --force "$BRANCH"
			$UPDATED=1
		fi

		LOCAL=$(git rev-parse @)
		REMOTE=$(git rev-parse @{u})
		BASE=$(git merge-base @ @{u})

		if [ $LOCAL = $BASE ]; then
			$UPDATED=1
		elif [ ! $LOCAL = $REMOTE ]; then
			git reset --quiet --hard origin/master
			git clean --quiet --force -dx
			$UPDATED=1
		fi

		if [ $UPDATED -eq 1 ]; then
			git pull --quiet
			git submodule update --quiet --init --recursive
		fi

		popd
	fi

	echo "$UPDATED"
}

function create_directory_forcefully {
	$PATH="$1"

	if [ -d "$PATH" ]; then
		return
	elif [ -f "$PATH" ]; then
		rm -f "$PATH"
	fi

	mkdir -p "$PATH"
}

validate_variable_or_set_default "MODULE_NAME"
validate_variable_or_set_default "REPOSITORY_DIR"
validate_variable_or_set_default "DEPENDENCIES" "$REPOSITORY_DIR/dependencies"
validate_variable_or_set_default "GARRYSMOD_COMMON_REPOSITORY" "https://github.com/danielga/garrysmod_common.git"
validate_variable_or_set_default "GARRYSMOD_COMMON" "$DEPENDENCIES/garrysmod_common"
validate_variable_or_set_default "TARGET_OS"
validate_variable_or_set_default "COMPILER_PLATFORM" "gmake"
validate_variable_or_set_default "PREMAKE5_EXECUTABLE" "premake5"
validate_variable_or_set_default "PREMAKE5" "premake5"
validate_variable_or_set_default "PROJECT_OS"

create_directory_forcefully "$DEPENDENCIES"
