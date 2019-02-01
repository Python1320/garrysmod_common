#!/bin/bash

# Exit if any command fails
set -e

# Checkout with the correct line endings on plain text files, depending on the host OS
git config --global core.autocrlf true >/dev/null 2>/dev/null

function validate_variable_or_set_default {
	NAME="$1"
	DEFAULT="$2"

	VALUE="$DEFAULT"
	if [ "${!NAME}" ]; then
		VALUE="${!NAME}"
	fi

	if [ -z "$VALUE" ] && [ -z "$DEFAULT" ]; then
		exit 1
	fi

	export "$NAME"="$VALUE"
}

function update_local_git_repository {
	DIRECTORY="$1"
	REPOSITORY="$2"
	BRANCH="${3:-master}"

	UPDATED=0
	if [ ! $(git -C "$DIRECTORY" rev-parse --is-inside-work-tree >/dev/null 2>/dev/null) ]; then
		rm -rf "$DIRECTORY"
		git clone --quiet --depth 1 --shallow-submodules --recursive "$REPOSITORY" "$DIRECTORY"
		UPDATED=1
	else
		pushd "$DIRECTORY"

		git fetch --quiet --all

		CURBRANCH=$(git symbolic-ref --quiet --short HEAD)
		if [ ! $BRANCH = $CURBRANCH ]; then
			git checkout --quiet --force "$BRANCH"
			UPDATED=1
		fi

		LOCAL=$(git rev-parse @)
		REMOTE=$(git rev-parse @{u})
		BASE=$(git merge-base @ @{u})

		if [ $LOCAL = $BASE ]; then
			UPDATED=1
		elif [ ! $LOCAL = $REMOTE ]; then
			git reset --quiet --hard origin/master
			git clean --quiet --force -dx
			UPDATED=1
		fi

		if [ $UPDATED -eq 1 ]; then
			git pull --quiet
			git submodule update --quiet --init --recursive
		fi

		popd
	fi

	echo "$UPDATED"
}

validate_variable_or_set_default "GARRYSMOD_COMMON_REPOSITORY" "https://github.com/danielga/garrysmod_common.git"
validate_variable_or_set_default "GARRYSMOD_COMMON" "./garrysmod_common"

update_local_git_repository "$GARRYSMOD_COMMON" "$GARRYSMOD_COMMON_REPOSITORY" "improve-build-scripts"
