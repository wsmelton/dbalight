# -----------------------------------------------------------------------------
# dbalight configuration file. Use this file to override the default
# parameter values used by the `Build-Module` command when building the module.
#
# For a full list of supported arguments run `Get-Help Build-Module -Full`.
# -----------------------------------------------------------------------------

@{
    ModuleManifest = "dbalight.psd1"
    VersionedOutputDirectory = $true
    CopyDirectories = @(
        'en-US'
        'dbalight/bin/Release/netstandard2.0/*'
    )
}