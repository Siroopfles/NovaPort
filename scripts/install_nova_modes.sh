#!/bin/bash

# --- Configuration ---
VERSION="${1:-v0.2.5-beta}" # Use first argument as version, otherwise default to latest stable beta
REPO_OWNER="Siroopfles"
REPO_NAME="NovaPort"
API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/git/trees/${VERSION}?recursive=1"
RAW_URL_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${VERSION}"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'

# --- Functions ---
show_banner() {
    echo -e "${CYAN}=============================================="
    echo -e "${CYAN}  Nova System Core Installer for Roo Code     "
    echo -e "${CYAN}  Downloading from branch/tag: ${VERSION}${NC}"
    echo -e "${CYAN}=============================================="
    echo
    echo "This script will download and install the core Nova System files:"
    echo "- The entire .nova/ directory"
    echo "- The entire .roo/ directory"
    echo "- .roomodes"
    echo "- README.md"
    echo "Other files like /examples, /scripts, LICENSE, etc., will be ignored."
    echo
}

check_deps() {
    if ! command -v curl &> /dev/null; then echo -e "${RED}Error: 'curl' is required but not installed.${NC}"; exit 1; fi
    if ! command -v jq &> /dev/null; then echo -e "${RED}Error: 'jq' is required. Please install it (e.g., 'brew install jq' or 'sudo apt-get install jq').${NC}"; exit 1; fi
}

# --- Main Script ---
clear
show_banner
check_deps

read -p "Enter the full path to your project directory (or press Enter to use the current directory): " TARGET_DIR

if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR=$(pwd)
    echo -e "${YELLOW}No path entered. Using current directory as target:${NC}"
    echo "$TARGET_DIR"
else
    # Expands tilde (~) to the home directory path
    TARGET_DIR="${TARGET_DIR/#\~/$HOME}"
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}Target directory '$TARGET_DIR' does not exist.${NC}"
    read -p "Do you want to create it? [y/n] " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "$TARGET_DIR" || { echo -e "${RED}Error: Could not create directory.${NC}"; exit 1; }
        echo -e "${GREEN}Successfully created directory: $TARGET_DIR${NC}"
    else
        echo "Installation cancelled."; exit
    fi
fi

echo -e "\n${YELLOW}Core system files will be installed into:${NC} $TARGET_DIR"
read -p "Are you sure you want to proceed? This will overwrite existing files. [y/n] " -n 1 -r; echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then echo "Installation cancelled."; exit; fi

echo -e "\n${CYAN}Starting installation...${NC}"

echo "Fetching file list from GitHub for version '${VERSION}'..."
API_RESPONSE=$(curl -sL "$API_URL")
# Use jq to get a list of all file paths from the API response
FILE_PATHS=$(echo "$API_RESPONSE" | jq -r '.tree[]? | select(.type == "blob") | .path')

if [[ "$(echo "$API_RESPONSE" | jq -r '.message?')" == "Not Found" || -z "$FILE_PATHS" ]]; then
    echo -e "${RED}Error: Could not retrieve file list from GitHub API. Ensure version '${VERSION}' exists.${NC}"
    exit 1
fi

DOWNLOAD_COUNT=0
for FILE_PATH in $FILE_PATHS; do
    # --- This is the filter logic ---
    # It uses a case statement to include a file only if its path matches one of these patterns.
    case "$FILE_PATH" in
        .roomodes|.nova/*|.roo/*|README.md)
            DEST_PATH="$TARGET_DIR/$FILE_PATH"
            mkdir -p "$(dirname "$DEST_PATH")"
            echo " - Downloading: $FILE_PATH"
            curl -sL -o "$DEST_PATH" "$RAW_URL_BASE/$FILE_PATH"
            ((DOWNLOAD_COUNT++))
            ;;
    esac
done

echo
echo -e "${GREEN}Installation complete! Downloaded $DOWNLOAD_COUNT core files.${NC}"
echo -e "${GREEN}The Nova System core files (version '${VERSION}') have been successfully installed into:${NC}"
echo "$TARGET_DIR"

exit 0