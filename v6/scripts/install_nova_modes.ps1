# PowerShell script to install Nova System modes by downloading them from the official GitHub repository.

# --- Configuration ---
$RepoOwner = "Siroopfles"
$RepoName = "NovaPort"
$Branch = "main"
$ApiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/git/trees/$Branch`?recursive=1"
$RawContentUrlBase = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch"

$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"

# --- Functions ---
function Show-Banner {
    Write-Host "==============================================" -ForegroundColor $Cyan
    Write-Host "  Nova System Modes Installer for Roo Code  " -ForegroundColor $Cyan
    Write-Host "==============================================" -ForegroundColor $Cyan
    Write-Host
    Write-Host "This script will download the latest Nova System files from the"
    Write-Host "GitHub repository ($RepoOwner/$RepoName) and install them into your project."
    Write-Host "It will skip versioned directories (like 'v1/', 'v2/', etc.)."
    Write-Host
}

# --- Main Script ---
Clear-Host
Show-Banner

# Prompt for the target directory
$targetDir = Read-Host -Prompt "Enter the full path to your target Roo Code project directory"

if (-not $targetDir -or ($targetDir.Trim() -eq "")) {
    Write-Host "Error: Target directory path cannot be empty." -ForegroundColor $Red; exit 1
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
Write-Host "Files will be downloaded from GitHub and installed into:" -ForegroundColor $Yellow
Write-Host "$targetDir"
Write-Host
$confirmChoice = Read-Host -Prompt "Are you sure you want to proceed? This may overwrite existing files. [y/n]"

if ($confirmChoice.ToLower() -ne 'y') {
    Write-Host "Installation cancelled."; exit
}

Write-Host
Write-Host "Starting installation..." -ForegroundColor $Cyan

try {
    # Get file list from GitHub API
    Write-Host "Fetching file list from GitHub..."
    $response = Invoke-WebRequest -Uri $ApiUrl -UseBasicParsing
    $allFiles = ($response.Content | ConvertFrom-Json).tree

    if (-not $allFiles) {
        throw "Could not retrieve file list from GitHub API."
    }

    # Filter the files based on user's rules
    $filesToDownload = $allFiles | Where-Object {
        $isBlob = $_.type -eq 'blob'
        $path = $_.path
        
        # Rule: Exclude versioned folders (e.g., v1/..., v1.2/...)
        $isExcluded = $path -match '^v[0-9.]+'

        # Rule: Include specific files and folders
        $isIncluded = ($path -eq '.roomodes' -or $path -eq 'README.md' -or $path -like '.nova/*' -or $path -like '.roo/*')
        
        $isBlob -and $isIncluded -and -not $isExcluded
    }

    Write-Host "Found $($filesToDownload.Count) files to download."

    foreach ($file in $filesToDownload) {
        $filePath = $file.path
        $destPath = Join-Path -Path $targetDir -ChildPath $filePath
        $destDir = Split-Path -Path $destPath -Parent

        if (-not (Test-Path -Path $destDir)) {
            New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        }

        $rawUrl = "$RawContentUrlBase/$($filePath.Replace('\', '/'))"
        Write-Host " - Downloading: $filePath"
        Invoke-WebRequest -Uri $rawUrl -OutFile $destPath -UseBasicParsing
    }

    Write-Host
    Write-Host "Installation complete!" -ForegroundColor $Green
    Write-Host "The Nova System files have been successfully installed into:" -ForegroundColor $Green
    Write-Host "$targetDir"

} catch {
    Write-Host
    Write-Host "An error occurred during installation:" -ForegroundColor $Red
    Write-Host $_.Exception.Message -ForegroundColor $Red
    Write-Host "Installation failed."
    exit 1
}