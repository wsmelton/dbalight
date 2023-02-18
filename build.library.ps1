[cmdletbinding()]
param(
    [ValidateSet('Debug','Release')]
    [string]
    $Configuration = 'Release'
)

$script:ModuleManifest = [IO.Path]::Combine($PSScriptRoot,'src','dbalight.psd1')
$script:ModuleTypes = [IO.Path]::Combine($PSScriptRoot,'src','dbalight.types.ps1xml')
$script:ModuleFormats = [IO.Path]::Combine($PSScriptRoot,'src','dbalight.format.ps1xml')
$script:ProjectRoot = [IO.Path]::Combine($PSScriptRoot,'src','dbalight')
$script:ProjectFile = [IO.Path]::Combine($ProjectRoot, 'dbalight.csproj')
$script:ProjectOut = [IO.Path]::Combine($PSScriptRoot,'src','output')
$script:ProjectLibFile = [IO.Path]::Combine($ProjectOut,'dbalight.dll')
$script:Manifest = Import-PowerShellDataFile -Path $ModuleManifest
$script:Version = $Manifest.ModuleVersion

# Ensure and call the module.
if ($MyInvocation.ScriptName -notlike '*Invoke-Build.ps1') {
    $InvokeBuildVersion = '5.10'
    $ErrorActionPreference = 'Stop'
    try {
        Import-Module InvokeBuild -MinimumVersion $InvokeBuildVersion
    } catch {
        Install-Module InvokeBuild -MinimumVersion $InvokeBuildVersion -Scope AllUsers -Force
        Import-Module InvokeBuild -MinimumVersion $InvokeBuildVersion
    }
    Invoke-Build -Task $Tasks -File $MyInvocation.MyCommand.Path @PSBoundParameters
    return
}

task Clean -Before Build {
    if (Test-Path $ProjectOut) {
        Remove-Item $ProjectOut -Recurse -Force
    }
}

task Build {
    exec { dotnet build --configuration $Configuration --output $ProjectOut /p:Version=$Version $ProjectFile }
    Get-ChildItem $ModuleManifest,$ModuleTypes,$ModuleFormats | Copy-Item -Destination $ProjectOut
}

task . build