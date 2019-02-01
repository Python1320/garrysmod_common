# Exit if any command fails
$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot/setup.psm1"

Install-Module -Name Invoke-MsBuild -Scope CurrentUser -Force

# Checkout with the correct line endings on plain text files, depending on the host OS
git config --global core.autocrlf true >$null 2>$null

UpdateLocalGitRepository $env:GARRYSMOD_COMMON -Repository $env:GARRYSMOD_COMMON_REPOSITORY -Branch "improve-build-scripts"

if ($env:SOURCE_SDK) {
	UpdateLocalGitRepository $env:SOURCE_SDK -Repository "https://github.com/danielga/sourcesdk-minimal.git"
}

$BUILD_PREMAKE5 = UpdateLocalGitRepository "$env:DEPENDENCIES/premake-core" -Repository "https://github.com/premake/premake-core.git"

CreateDirectoryForcefully "$env:DEPENDENCIES/$env:PROJECT_OS"

if ($BUILD_PREMAKE5) {
	Write-Output "premake-core needs building, bootstrapping"
	Push-Location "$env:DEPENDENCIES/premake-core"
	$env:CL = "/MP"
	nmake -f Bootstrap.mak "$env:PROJECT_OS"
	Pop-Location
	CreateDirectoryForcefully("$env:DEPENDENCIES/$env:PROJECT_OS/premake-core")
	Copy-Item "$env:DEPENDENCIES/premake-core/bin/release/$env:PREMAKE5_EXECUTABLE" $env:PREMAKE5
}
