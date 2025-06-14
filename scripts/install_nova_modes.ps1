# PowerShell script to install or update the core Nova System files from the official GitHub repository.
# Modernized to dynamically fetch versions from the GitHub API.

# Param block for user inputs
param(
    # Specifies the version to install. Can be:
    # - A specific tag name (e.g., "v0.3.0-beta")
    # - "latest" for the latest stable release
    # - "latest-prerelease" for the latest pre-release
    # - "main" for the stable main branch
    # - "dev" for the latest development branch
    [ValidateSet("latest", "latest-prerelease", "main", "dev")]
    [string]$Version = "latest-prerelease"
)

# --- Configuration ---
$RepoOwner = "Siroopfles"
$RepoName = "NovaPort"
$GitHubApiBaseUrl = "https://api.github.com/repos/$RepoOwner/$RepoName"

# ANSI Colors for better output
$Reset = "$([char]27)[0m"
$Red = "$([char]27)[91m"
$Green = "$([char]27)[92m"
$Yellow = "$([char]27)[93m"
$Cyan = "$([char]27)[96m"

# --- Functions ---
function Show-Banner {
    Write-Host "${Cyan}====================================================="
    Write-Host "  Nova System - Modern Core Installer for Roo Code "
    Write-Host "=====================================================${Reset}"
    Write-Host
    Write-Host "This script will download and install the core Nova System files into a"
    Write-Host "directory of your choice. It selectively installs:"
    Write-Host "- The entire .nova/ directory (workflows, docs, etc.)"
    Write-Host "- The entire .roo/ directory (custom system prompts)"
    Write-Host "- The .roomodes file"
    Write-Host "- The main README.md"
    Write-Host
}

function Get-GitHubTarget {
    param(
        [string]$ReleaseType # "latest", "latest-prerelease", "main", "dev", or a specific tag
    )
    
    if ($ReleaseType -in ("main", "dev")) {
        return $ReleaseType
    }
    
    if ($ReleaseType -eq "latest-prerelease") {
        $apiUrl = "$GitHubApiBaseUrl/releases"
        try {
            Write-Host "${Yellow}Fetching all releases to find the latest pre-release...${Reset}"
            $releases = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers @{"Accept"="application/vnd.github.v3+json"}
            $latestPrerelease = $releases | Where-Object { $_.prerelease -eq $true } | Sort-Object { $_.published_at } -Descending | Select-Object -First 1
            if ($latestPrerelease) {
                return $latestPrerelease.tag_name
            } else {
                Write-Warning "No pre-releases found. Falling back to the latest stable release."
                $ReleaseType = "latest" # Fallback
            }
        } catch {
            throw "Failed to fetch releases from GitHub API. Please check your connection and the repository details."
        }
    }
    
    if ($ReleaseType -eq "latest") {
        $apiUrl = "$GitHubApiBaseUrl/releases/latest"
        try {
            Write-Host "${Yellow}Fetching latest stable release tag from GitHub API...${Reset}"
            $releaseInfo = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers @{"Accept"="application/vnd.github.v3+json"}
            return $releaseInfo.tag_name
        } catch {
            throw "Failed to fetch the latest release tag. $_"
        }
    }

    # If not a keyword, assume it's a specific tag
    return $ReleaseType
}

# --- Main Script ---
Clear-Host
Show-Banner

# Resolve the target version ref (tag or branch)
$targetRef = $Version
if ($Version -in ("latest", "latest-prerelease", "main", "dev")) {
    try {
        $targetRef = Get-GitHubTarget -ReleaseType $Version
    } catch {
        Write-Host "${Red}Error: $($_.Exception.Message)${Reset}"
        exit 1
    }
}
Write-Host "${Cyan}Selected Version: ${Yellow}$Version${Reset} -> Resolved to Ref: ${Yellow}$targetRef${Reset}"
Write-Host

# Setup final URLs
$TreeApiUrl = "$GitHubApiBaseUrl/git/trees/$targetRef`?recursive=1"
$RawContentUrlBase = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$targetRef"

# Get target directory
$targetDir = Read-Host -Prompt "Enter the full path to your project directory (or press Enter for current: '$(Get-Location)')"
if (-not $targetDir) { $targetDir = Get-Location }

Write-Host
Write-Host "${Yellow}Files will be installed into:${Cyan} $targetDir ${Reset}"
$confirm = Read-Host "This may overwrite existing files. Proceed? [y/n]"
if ($confirm.ToLower() -ne 'y') {
    Write-Host "${Red}Installation cancelled.${Reset}"
    exit
}

Write-Host
Write-Host "${Cyan}Starting installation...${Reset}"

try {
    Write-Host "Fetching file list from GitHub for ${Yellow}$targetRef${Reset}..."
    $response = Invoke-RestMethod -Uri $TreeApiUrl
    if (-not $response.tree) { throw "Could not retrieve file list from GitHub API for '$targetRef'. Please ensure the tag/branch exists." }
    
    $filesToDownload = $response.tree | Where-Object {
        $_.type -eq 'blob' -and ($_.path -eq '.roomodes' -or $_.path -eq 'README.md' -or $_.path -like '.nova/*' -or $_.path -like '.roo/*')
    }

    if ($filesToDownload.Count -eq 0) {
        throw "No core system files found for version '$targetRef'. The repository structure might have changed."
    }

    Write-Host "Found $($filesToDownload.Count) core files to download."

    foreach ($file in $filesToDownload) {
        $filePath = $file.path
        $destPath = Join-Path -Path $targetDir -ChildPath $filePath
        $destDir = Split-Path -Path $destPath -Parent
        if (-not (Test-Path -Path $destDir)) { 
            New-Item -ItemType Directory -Force -Path $destDir | Out-Null 
        }
        
        $rawUrl = "$RawContentUrlBase/$($filePath.Replace('\', '/'))"
        Write-Host " - Downloading: $filePath" -NoNewline
        Invoke-WebRequest -Uri $rawUrl -OutFile $destPath -UseBasicParsing
        Write-Host " -> ${Green}Done${Reset}"
    }

    Write-Host
    Write-Host "${Green}Installation Complete!${Reset}"
    Write-Host "Nova System core files (version ${Yellow}$targetRef${Reset}) have been installed into:"
    Write-Host "${Cyan}$targetDir${Reset}"

} catch {
    Write-Host
    Write-Host "${Red}An error occurred during installation:${Reset}"
    Write-Host "${Red}$($_.Exception.Message)${Reset}"
    Write-Host "Please check the version/ref name and your internet connection."
    exit 1
}