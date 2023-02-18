#requires -Module InvokeBuild
[cmdletbinding()]
param(
    [Parameter(ParameterSetName = 'docs')]
    [switch]
    $PublishDocs,

    [Parameter(ParameterSetName = 'publish')]
    [string]
    $GalleryKey,

    [Parameter(ParameterSetName = 'publish')]
    [switch]
    $Prerelease,

    [Parameter(ParameterSetName = 'release')]
    [Parameter(ParameterSetName = 'publish')]
    [switch]
    $Release,

    [Parameter(ParameterSetName = 'release')]
    [Parameter(ParameterSetName = 'publish')]
    [switch]
    $Draft,

    [Parameter(ParameterSetName = 'publish')]
    [switch]
    $SkipTests
)
Push-Location
Set-Location $PSScriptRoot
$moduleName = 'dbalight'
$staging = "$env:TEMP\dbalight_staging\"

$git = git status
if ($git[1] -notmatch "Your branch is up to date" -and (-not $PSBoundParameters.ContainsKey('PublishDocs'))) {
    Pop-Location
    throw "Local branch is dirty"
}

if (Test-Path $staging) {
    Remove-Item -Recurse -Force $staging
}

if (Get-Module dbalight) {
    Remove-Module dbalight -Force
}

$imported = Import-Module "$PSScriptRoot\src\dbalight.psd1" -Force -PassThru

if ($PSBoundParameters['PublishDocs']) {
    if ($PSEdition -eq 'Desktop') {
        Write-Warning "Doc processing has to run under PowerShell Core"
        return
    }
    $docCommandPath = "$PSScriptRoot\docs\"
    Write-Host "Removing old command docs [$docCommandPath]" -ForegroundColor Black -BackgroundColor DarkCyan
    Remove-Item $docCommandPath -Filter *.md -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue -Verbose

    Import-Module platyPS
    $cmdParams = @{
        Module      = $moduleName
        CommandType = 'Cmdlet'
    }
    $commands = Get-Command @cmdParams

    Write-Host "Generating new command docs [$docCommandPath]" -ForegroundColor Black -BackgroundColor DarkCyan
    foreach ($cmd in $commands) {
        switch ($cmd.Name) {
            { $_ -match 'Db' } { $category = 'database' }
            { $_ -match 'Instance' } { $category = 'instance' }
            default { $category = 'general' }
        }
        $metadata = @{
            'category' = $category
            'title'    = $cmd.Name
        }

        New-MarkdownHelp -OutputFolder $docCommandPath -Command $cmd.Name -Metadata $metadata -Force
    }
    return
}

if (-not $PSBoundParameters['SkipTests']) {
    Import-Module Pester
    $tests = Invoke-Pester -Path "$PSScriptRoot\tests" -Output Minimal -PassThru
}

if ($PSBoundParameters['Prerelease']) {
    $foundModule = Find-Module -Name $moduleName -AllowPrerelease:$Prerelease
} else {
    $foundModule = Find-Module -Name $moduleName
}

if ($foundModule.Version -ge $imported.Version) {
    Write-Warning "PowerShell Gallery version of $moduleName is more recent ($($foundModule.Version) >= $($imported.Version))"
}

if ($tests.FailedCount -eq 0 -or $PSBoundParameters['SkipTests']) {
    $moduleTempPath = Join-Path $staging $moduleName
    Write-Host "Staging directory: $moduleTempPath"
    $imported | Split-Path | Copy-Item -Destination $moduleTempPath -Recurse

    if ($PSBoundParameters['GalleryKey']) {
        try {
            Write-Host "Publishing $moduleName [$($imported.Version)] to PowerShell Gallery"

            Publish-Module -Path $moduleTempPath -NuGetApiKey $gallerykey
            Write-Host "successfully published to PS Gallery"
        } catch {
            Write-Warning "Publish failed: $_"
        }
    }
    if ($PSBoundParameters['Release']) {
        if ((gh config get prompt) -eq 'enabled') {
            Invoke-Expression "gh config set prompt disabled"
        }
        $moduleData = Import-PowerShellDataFile "$staging\$moduleName\$moduleName.psd1"
        $changeLog = [IO.Path]::Combine([string]$PSScriptRoot, 'release.md')
        Compress-Archive "$staging\$moduleName\*" -DestinationPath "$staging\$moduleName.zip" -CompressionLevel Fastest -Force
        $ghArgs = "release create `"v$($moduleData.ModuleVersion)`" `"$($staging)$($moduleName).zip#$($moduleName).zip`" --title `"dbalight $($moduleData.ModuleVersion)`" --notes-file $changeLog"
        if ($PSBoundParameters['Prerelease']) {
            $ghArgs = $ghArgs + " --prerelease"
        }
        if ($PSBoundParameters['Draft']) {
            $ghArgs = $ghArgs + " --draft"
        }

        Write-Host "gh command to execute: $ghArgs" -ForegroundColor DarkYellow

        Invoke-Expression "gh $ghArgs"

        if ((gh config get prompt) -eq 'disabled') {
            Invoke-Expression "gh config set prompt enabled"
        }
    }

    Remove-Item -Recurse -Force $staging
} else {
    Remove-Item -Recurse -Force $staging
    Write-Host "Tests failures detected; cancelling and cleaning up"
}
Pop-Location