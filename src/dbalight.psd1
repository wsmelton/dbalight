@{
    ModuleVersion        = '0.1.0'
    Description          = 'A light to shine into your SQL Server environment that can be used for reporting, inventory, or to find 💩.'
    CompatiblePSEditions = 'Desktop', 'Core'
    RootModule           = 'dbalight.psm1'
    TypesToProcess       = 'dbalight.types.ps1xml'
    FormatsToProcess     = 'dbalight.format.ps1xml'
    GUID                 = '527d50d0-c8f3-4947-a204-27f343a39da7'
    Author               = 'Shawn Melton'
    CompanyName          = 'Shawn Melton'
    Copyright            = '(c) 2021. All rights reserved.'
    PowerShellVersion    = '7.1'
    PrivateData          = @{
        PSData = @{
            PreRelease   = 'beta'
            Tags         = 'sqlserver', 'devops', 'dba', 'sqltools'
            ProjectURI   = 'https://github.com/wsmelton/dbalight'
            LicenseURI   = 'https://github.com/wsmelton/dbalight/blob/main/LICENSE'
            ReleaseNotes = 'https://github.com/wsmelton/dbalight/blob/main/CHANGELOG.md'
        }
    }
    DefaultCommandPrefix = 'Dl'
}