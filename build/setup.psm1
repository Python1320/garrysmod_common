# Exit if any command fails
$ErrorActionPreference = "Stop"
# Do not ask for confirmation
$ConfirmPreference = "None"
# Fail if any unset variable is used
Set-StrictMode -Version Latest
# Allow running scripts coming from the Internet
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force

# $name cannot be empty or Test-Path will go nuts
function ValidateVariableOrSetDefault([string]$Name, $Default = $null) {
	$value = $Default
	if (Test-Path env:$Name -ErrorAction SilentlyContinue) {
		$value = Get-Item Env:$Name
	}

	if (Get-Variable $Name -ErrorAction SilentlyContinue) {
		$value = Get-Variable $Name
	}

	if ($null -eq $value) {
		if ($null -eq $Default) {
			throw "'$Name' was not set"
		}

		Set-Variable env:$Name -Value $Default
	}
}

function UpdateLocalGitRepository([string]$Repository, [string]$Directory, [string]$Branch = "master") {
	$updated = $false

	if ((Get-Item $Directory -ErrorAction SilentlyContinue) -is [System.IO.DirectoryInfo]) {
		git -C "$Directory" rev-parse --is-inside-work-tree >$null 2>$null
	} else {
		$LastExitCode = 128
	}

	if ($LastExitCode -ne 0) {
		Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $Directory
		git clone --quiet --depth 1 --shallow-submodules --recursive "$Repository" "$Directory"
		$updated = $true
	} else {
		Push-Location $Directory

		git fetch --quiet --all

		$curbranch = git symbolic-ref --quiet --short HEAD
		if ($curbranch -ne $Branch) {
			git checkout --quiet --force "$Branch"
			$updated = $true
		}

		$local = git rev-parse "@"
		$remote = git rev-parse "@{u}"
		$base = git merge-base "@" "@{u}"

		if ($local -eq $base) {
			$updated = $true
		} elseif ($local -ne $remote) {
			git reset --quiet --hard
			git clean --quiet --force -dx
			$updated = $true
		}

		if ($updated) {
			git pull --quiet
			git submodule update --quiet --init --recursive
		}

		Pop-Location
	}

	return $updated
}

function CreateDirectoryForcefully([string]$Path) {
	$item = Get-Item $Path -ErrorAction SilentlyContinue
	if ($item) {
		if ($item -is [System.IO.DirectoryInfo]) {
			return
		}

		Remove-Item -Force $Path
	}

	New-Item $Path -ItemType Directory
}

ValidateVariableOrSetDefault "MODULE_NAME" -Default (Split-Path (Split-Path $PSScriptRoot -Parent) -Leaf)
ValidateVariableOrSetDefault "REPOSITORY_DIR" -Default "$PSScriptRoot"
ValidateVariableOrSetDefault "DEPENDENCIES" -Default "$env:REPOSITORY_DIR/dependencies"
ValidateVariableOrSetDefault "GARRYSMOD_COMMON_REPOSITORY" -Default "https://github.com/danielga/garrysmod_common.git"
ValidateVariableOrSetDefault "GARRYSMOD_COMMON" -Default "$env:DEPENDENCIES/garrysmod_common"
ValidateVariableOrSetDefault "TARGET_OS" -Default "windows"
ValidateVariableOrSetDefault "COMPILER_PLATFORM" -Default "vs2017"
ValidateVariableOrSetDefault "PREMAKE5_EXECUTABLE" -Default "premake5.exe"
ValidateVariableOrSetDefault "PREMAKE5" -Default "premake5.exe"
ValidateVariableOrSetDefault "PROJECT_OS" -Default "windows"

CreateDirectoryForcefully $env:DEPENDENCIES

Export-ModuleMember -Function ValidateVariableOrSetDefault, UpdateLocalGitRepository, CreateDirectoryForcefully
