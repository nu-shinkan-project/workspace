$ErrorActionPreference = 'Stop'

$scriptDirectory = $PSScriptRoot
$workspaceDirectory = Split-Path -Parent $scriptDirectory
$repositoryOrganization = if ($env:WORKSPACE_REPOSITORY_ORG) { $env:WORKSPACE_REPOSITORY_ORG } else { 'nu-shinkan-project' }
$reposFile = Join-Path $scriptDirectory 'repos'

# -----------------------
# Clone missing repositories
# -----------------------

foreach ($entry in Get-Content -LiteralPath $reposFile) {
    # Ignore blank lines and comments.
    if (-not $entry -or $entry.StartsWith('#')) {
        continue
    }

    # An entry may be a complete Git URL or a repository name in the default org.
    if ($entry -match '^(https?://|git@|ssh://)') {
        $repositoryUrl = $entry
        $repositoryName = [IO.Path]::GetFileName($entry) -replace '\.git$', ''
    } else {
        $repositoryName = $entry -replace '\.git$', ''
        $repositoryUrl = "https://github.com/$repositoryOrganization/$repositoryName.git"
    }

    $repositoryPath = Join-Path $workspaceDirectory $repositoryName

    # Never modify a repository—or any other path—that already exists.
    $existingPath = Get-Item -LiteralPath $repositoryPath -Force -ErrorAction SilentlyContinue

    if ($null -ne $existingPath) {
        Write-Host "Skipping existing path: $repositoryPath"
        continue
    }

    & git clone -- $repositoryUrl $repositoryPath

    if ($LASTEXITCODE -ne 0) {
        throw "git clone failed for $repositoryUrl"
    }
}
