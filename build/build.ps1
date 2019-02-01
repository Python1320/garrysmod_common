# Exit if any command fails
$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot/install_dependencies.psm1"

Import-Module Invoke-MsBuild

Push-Location "$env:REPOSITORY_DIR/projects"
& "$env:PREMAKE5" "$env:COMPILER_PLATFORM"
Pop-Location

Push-Location "$env:REPOSITORY_DIR/projects/$env:PROJECT_OS/$env:COMPILER_PLATFORM"
Invoke-MsBuild -Path "$env:MODULE_NAME.sln" -MsBuildParameters "/nodeReuse:false /p:UseSharedCompilation=false /p:Configuration=Release /p:Platform=Win32 /m" -BypassVisualStudioDeveloperCommandPrompt -ShowBuildOutputInCurrentWindow
Pop-Location
