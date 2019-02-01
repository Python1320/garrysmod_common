#!/bin/bash

# Exit if any command fails and if any unset variable is used
set -eu

# Checkout with the correct line endings on plain text files, depending on the host OS
git config --global core.autocrlf true >/dev/null 2>/dev/null

function validate_variable {
	NAME="$1"

	value=""
	if [ "${!NAME}" ]; then
		value="${!NAME}"
	fi

	if [ -z "$value" ]; then
		exit 1
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

validate_variable "GARRYSMOD_COMMON_REPOSITORY"
validate_variable "GARRYSMOD_COMMON"

update_local_git_repository "$GARRYSMOD_COMMON" "$GARRYSMOD_COMMON_REPOSITORY" "improve-build-scripts"
