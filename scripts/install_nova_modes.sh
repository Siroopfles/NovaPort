#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
REPO_OWNER="Siroopfles"
REPO_NAME="NovaPort"
GITHUB_API_BASE_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}"

# --- Colors ---
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'

# --- Functions ---
show_banner() {
    echo -e "${CYAN}====================================================="
    echo -e "  Nova System - Modern Core Installer for Roo Code "
    echo -e "=====================================================${RESET}"
    echo
    echo "This script will download and install the core Nova System files:"
    echo "- The entire .nova/ directory (workflows, docs, etc.)"
    echo "- The entire .roo/ directory (custom system prompts)"
    echo "- The .roomodes file and README.md"
    echo
}

check_deps() {
    command -v curl >/dev/null 2>&1 || { echo -e "${RED}Error: 'curl' is required but not installed.${RESET}"; exit 1; }
    command -v jq >/dev/null 2>&1 || { echo -e "${RED}Error: 'jq' is required. Please install it (e.g., 'brew install jq' or 'sudo apt-get install jq').${RESET}"; exit 1; }
}

get_github_target() {
    local release_type=$1
    local api_url

    if [[ "$release_type" == "main" || "$release_type" == "dev" ]]; then
        # The keywords 'main' or 'dev' directly map to the respective branches
        echo "$release_type"
        return
    fi
    
    if [[ "$release_type" == "latest-prerelease" ]]; then
        api_url="${GITHUB_API_BASE_URL}/releases"
        echo -e "${YELLOW}Fetching all releases to find the latest pre-release...${RESET}"
        tag=$(curl -sL "$api_url" | jq -r '[.[] | select(.prerelease == true)][0].tag_name')
        if [[ -n "$tag" && "$tag" != "null" ]]; then
            echo "$tag"
            return
        else
            echo -e "${YELLOW}Warning: No pre-releases found. Falling back to the latest stable release.${RESET}"
            release_type="latest" # Fallback
        fi
    fi
    
    if [[ "$release_type" == "latest" ]]; then
        api_url="${GITHUB_API_BASE_URL}/releases/latest"
        echo -e "${YELLOW}Fetching latest stable release tag from GitHub API...${RESET}"
        tag=$(curl -sL "$api_url" | jq -r '.tag_name')
        if [[ -z "$tag" || "$tag" == "null" ]]; then
            echo -e "${RED}Error: Could not fetch the latest release tag from GitHub.${RESET}" >&2
            exit 1
        fi
        echo "$tag"
        return
    fi
    
    # If not a keyword, assume it's a specific tag
    echo "$release_type"
}

# --- Main Script ---
clear
show_banner
check_deps

# Process argument for version
VERSION_ARG="${1:-latest-prerelease}" # Default to latest-prerelease if no argument is given

# Resolve the target tag/branch
TARGET_REF=$(get_github_target "$VERSION_ARG")
echo -e "${CYAN}Selected Version: ${YELLOW}${VERSION_ARG}${RESET} -> Resolved to Ref: ${YELLOW}${TARGET_REF}${RESET}"
echo

# Get target directory
read -p "Enter the full path for installation (or press Enter for current: '$(pwd)'): " TARGET_DIR
TARGET_DIR="${TARGET_DIR:-$(pwd)}" # Default to current directory if empty
TARGET_DIR="${TARGET_DIR/#\~/$HOME}" # Expand tilde

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}Target directory '$TARGET_DIR' does not exist.${RESET}"
    read -p "Create it? [y/n] " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "$TARGET_DIR"
        echo -e "${GREEN}Successfully created directory: $TARGET_DIR${RESET}"
    else
        echo -e "${RED}Installation cancelled.${RESET}"; exit 1
    fi
fi

echo -e "\n${YELLOW}Files will be installed into: ${CYAN}${TARGET_DIR}${RESET}"
read -p "This may overwrite existing files. Proceed? [y/n] " -n 1 -r; echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation cancelled.${RESET}"; exit 1
fi

echo -e "\n${CYAN}Starting installation...${RESET}"

TREE_API_URL="${GITHUB_API_BASE_URL}/git/trees/${TARGET_REF}?recursive=1"
RAW_URL_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${TARGET_REF}"

echo "Fetching file list from GitHub for ${YELLOW}${TARGET_REF}${RESET}..."
FILE_PATHS=$(curl -sL "$TREE_API_URL" | jq -r '.tree[]? | select(.type == "blob") | .path')

if [[ -z "$FILE_PATHS" ]]; then
    echo -e "${RED}Error: Could not retrieve file list for ref '${TARGET_REF}'. Ensure the tag/branch exists.${RESET}"
    exit 1
fi

DOWNLOAD_COUNT=0
for FILE_PATH in $FILE_PATHS; do
    case "$FILE_PATH" in
        .roomodes|README.md|.nova/*|.roo/*)
            DEST_PATH="${TARGET_DIR}/${FILE_PATH}"
            mkdir -p "$(dirname "$DEST_PATH")"
            
            echo -n " - Downloading: $FILE_PATH"
            curl -sL -o "$DEST_PATH" "${RAW_URL_BASE}/${FILE_PATH}"
            echo -e " -> ${GREEN}Done${RESET}"
            ((DOWNLOAD_COUNT++))
            ;;
    esac
done

if [[ $DOWNLOAD_COUNT -eq 0 ]]; then
    echo -e "${RED}Error: No core system files were found for version '${TARGET_REF}'. The repository structure might have changed.${RESET}"
    exit 1
fi

echo
echo -e "${GREEN}Installation Complete! Downloaded $DOWNLOAD_COUNT core files.${RESET}"
echo -e "Nova System (version ${YELLOW}${TARGET_REF}${RESET}) has been installed into:"
echo -e "${CYAN}${TARGET_DIR}${RESET}"

exit 0