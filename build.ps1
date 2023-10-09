#requires -Version 7.2
#requires -Modules ModuleBuilder
<#
    .SYNOPSIS
    Script to build the dbalight solution and module
#>
[CmdletBinding()]
param(
    # A specific folder to build into, defaults to workspace root
    [string]
    $OutputDirectory = "Output",

    # The version of the output module
    [Alias("ModuleVersion")]
    [string]
    $SemVer
)

$ErrorView = 'DetailedView'
$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot -StackName builderscript
$OutputDirectory = Join-Path $Pwd $OutputDirectory

$dllFileName = 'dbalight.dll'
if (-not (Get-Command dotnet -CommandType Application -ErrorAction Ignore)) {
    throw "dotnet not found installed or in your path"
}

if (-not $SemVer) {
    if ($SemVer = dotnet gitversion -showvariable SemVer) {
        $null = $PSBoundParameters.Add("SemVer", $SemVer)
    }
}

<# clean it before we build it #>
dotnet clean -c release

<# now we build #>
$VersionNuget = dotnet gitversion -showvariable NuGetVersion -config ./GitVersion.yml
$VersionPrefix, $VersionSuffix = $VersionNuget -split '[-+]', 2
dotnet build -c release -p:VersionPrefix=$VersionPrefix -p:VersionSuffix=$VersionSuffix

<# Find the DLL #>
$dll = Get-ChildItem -Recurse -File -Filter $dllFileName | Select-Object -First 1
if ($dll) {
    Write-Host "dotnet build successful, found $($dll.FullName)"
    Write-Host " - Build $($Module.Name) $SemVer" -ForegroundColor Cyan
    Build-Module -SourcePath ./source -Target CleanBuild -OutputDirectory $OutputDirectory
} else {
    Write-Warning "Module-Builder could not run, unable to find DLL library: $dllFileName"
}