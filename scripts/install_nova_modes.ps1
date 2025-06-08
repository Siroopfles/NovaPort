# PowerShell script to install Nova System modes by downloading them from the official GitHub repository.
# It accepts an optional -Version parameter (e.g., -Version v0.1.0-beta). Defaults to 'main'.
param(
    [string]$Version = "main"
)

# --- Configuration ---
$RepoOwner = "Siroopfles"
$RepoName = "NovaPort"
$ApiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/git/trees/$Version`?recursive=1"
$RawContentUrlBase = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Version"

$Green = "Green"; $Yellow = "Yellow"; $Red = "Red"; $Cyan = "Cyan"

# --- Functions ---
function Show-Banner {
    Write-Host "==============================================" -ForegroundColor $Cyan
    Write-Host "  Nova System Modes Installer for Roo Code  " -ForegroundColor $Cyan
    Write-Host "  Downloading version: $Version" -ForegroundColor $Yellow
    Write-Host "==============================================" -ForegroundColor $Cyan
    Write-Host
    Write-Host "This script will download Nova System files from GitHub and install them."
    Write-Host "It will skip versioned directories (like 'v1/', 'v2/', etc.)."
    Write-Host
}

# --- Main Script ---
Clear-Host
Show-Banner

# Prompt for the target directory, allowing for a default
$targetDirInput = Read-Host -Prompt "Enter the full path to your project directory (or press Enter to use the current directory)"

if (-not $targetDirInput -or ($targetDirInput.Trim() -eq "")) {
    $targetDir = Get-Location
    Write-Host "No path entered. Using current directory as target:" -ForegroundColor $Yellow
    Write-Host $targetDir
} else {
    $targetDir = $targetDirInput
}

if (-not (Test-Path -Path $targetDir -PathType Container)) {
    Write-Host "Target directory '$targetDir' does not exist." -ForegroundColor $Yellow
    $createChoice = Read-Host -Prompt "Do you want to create it? [y/n]"
    if ($createChoice.ToLower() -eq 'y') {
        try {
            New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
            Write-Host "Successfully created directory: $targetDir" -ForegroundColor $Green
        } catch {
            Write-Host "Error: Could not create directory." -ForegroundColor $Red; Write-Host $_.Exception.Message -ForegroundColor $Red; exit 1
        }
    } else {
        Write-Host "Installation cancelled."; exit
    }
}

Write-Host
Write-Host "Files will be downloaded and installed into:" -ForegroundColor $Yellow
Write-Host "$targetDir"
Write-Host
$confirmChoice = Read-Host -Prompt "Are you sure you want to proceed? This may overwrite existing files. [y/n]"

if ($confirmChoice.ToLower() -ne 'y') {
    Write-Host "Installation cancelled."; exit
}

Write-Host
Write-Host "Starting installation..." -ForegroundColor $Cyan

try {
    Write-Host "Fetching file list from GitHub for version '$Version'..."
    $response = Invoke-WebRequest -Uri $ApiUrl -UseBasicParsing
    $allFiles = ($response.Content | ConvertFrom-Json).tree
    if (-not $allFiles) { throw "Could not retrieve file list from GitHub API. Ensure version '$Version' exists." }

    $filesToDownload = $allFiles | Where-Object {
        $isBlob = $_.type -eq 'blob'
        $path = $_.path
        $isExcluded = $path -match '^v[0-9.]+'
        $isIncluded = ($path -eq '.roomodes' -or $path -eq 'README.md' -or $path -like '.nova/*' -or $path -like '.roo/*')
        $isBlob -and $isIncluded -and -not $isExcluded
    }

    Write-Host "Found $($filesToDownload.Count) files to download."

    foreach ($file in $filesToDownload) {
        $filePath = $file.path
        $destPath = Join-Path -Path $targetDir -ChildPath $filePath
        $destDir = Split-Path -Path $destPath -Parent
        if (-not (Test-Path -Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
        
        $rawUrl = "$RawContentUrlBase/$($filePath.Replace('\', '/'))"
        Write-Host " - Downloading: $filePath"
        Invoke-WebRequest -Uri $rawUrl -OutFile $destPath -UseBasicParsing
    }

    Write-Host
    Write-Host "Installation complete!" -ForegroundColor $Green
    Write-Host "The Nova System files (version '$Version') have been successfully installed into:" -ForegroundColor $Green
    Write-Host "$targetDir"

} catch {
    Write-Host
    Write-Host "An error occurred during installation:" -ForegroundColor $Red
    Write-Host $_.Exception.Message -ForegroundColor $Red
    Write-Host "Installation failed. Please check the version name and your internet connection."
    exit 1
}