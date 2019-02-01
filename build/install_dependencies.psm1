# Exit if any command fails
$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot/setup.psm1"

Install-Module -Name Invoke-MsBuild -Scope CurrentUser -Force

Add-Type -AssemblyName System.IO.Compression.FileSystem

# Checkout with the correct line endings on plain text files, depending on the host OS
git config --global core.autocrlf true >$null 2>$null

UpdateLocalGitRepository $env:GARRYSMOD_COMMON -Repository $env:GARRYSMOD_COMMON_REPOSITORY -Branch "improve-build-scripts"

if ($env:SOURCE_SDK) {
	UpdateLocalGitRepository $env:SOURCE_SDK -Repository "https://github.com/danielga/sourcesdk-minimal.git"
}

if (!(Get-Item $env:PREMAKE5 -ErrorAction SilentlyContinue) -is [System.IO.FileInfo]) {
	$PremakeDirectory = "$env:DEPENDENCIES/$env:PROJECT_OS/premake-core"
	$PremakeZipPath = "$PremakeDirectory/premake-core.zip"
	CreateDirectoryForcefully $PremakeDirectory
	(New-Object System.Net.WebClient).DownloadFile("https://github.com/premake/premake-core/releases/download/v5.0.0-alpha13/premake-5.0.0-alpha13-windows.zip", $PremakeZipPath)
	[System.IO.Compression.ZipFile]::ExtractToDirectory($PremakeZipPath, $PremakeDirectory)
	Remove-Item $PremakeZipPath -Force
}
