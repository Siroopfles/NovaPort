#!/bin/bash

# Bash script to install Nova System modes by downloading them from the official GitHub repository.

# --- Configuration ---
REPO_OWNER="Siroopfles"
REPO_NAME="NovaPort"
BRANCH="main"
API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/git/trees/${BRANCH}?recursive=1"
RAW_URL_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Functions ---
show_banner() {
    echo -e "${CYAN}==============================================${NC}"
    echo -e "${CYAN}  Nova System Modes Installer for Roo Code  ${NC}"
    echo -e "${CYAN}==============================================${NC}"
    echo
    echo "This script will download the latest Nova System files from the"
    echo -e "GitHub repository (${YELLOW}${REPO_OWNER}/${REPO_NAME}${NC}) and install them into your project."
    echo "It will skip versioned directories (like 'v1/', 'v2/', etc.)."
    echo
}

check_deps() {
    if ! command -v curl &> /dev/null; then echo -e "${RED}Error: 'curl' is required but not installed.${NC}"; exit 1; fi
    if ! command -v jq &> /dev/null; then echo -e "${RED}Error: 'jq' is required. Please install it (e.g., 'brew install jq').${NC}"; exit 1; fi
}

# --- Main Script ---
clear
show_banner
check_deps

# Prompt for the target directory, allowing for a default
read -p "Enter the full path to your target project directory (or press Enter to use the current directory): " TARGET_DIR

# If user presses Enter, use the current directory. Otherwise, use their input.
if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR=$(pwd)
    echo -e "${YELLOW}No path entered. Using current directory as target:${NC}"
    echo "$TARGET_DIR"
else
    # Handle tilde expansion only if a path was provided
    TARGET_DIR="${TARGET_DIR/#\~/$HOME}"
fi

# The rest of the script remains the same
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

echo -e "\n${YELLOW}Files will be installed into:${NC} $TARGET_DIR"
read -p "Are you sure you want to proceed? This may overwrite existing files. [y/n] " -n 1 -r; echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then echo "Installation cancelled."; exit; fi

echo -e "\n${CYAN}Starting installation...${NC}"

echo "Fetching file list from GitHub..."
FILE_PATHS=$(curl -sSL "$API_URL" | jq -r '.tree[] | select(.type == "blob") | .path')
if [[ -z "$FILE_PATHS" ]]; then echo -e "${RED}Error: Could not retrieve file list from GitHub API.${NC}"; exit 1; fi

DOWNLOAD_COUNT=0
for FILE_PATH in $FILE_PATHS; do
    if [[ "$FILE_PATH" =~ ^v[0-9.]+/ ]]; then continue; fi

    case "$FILE_PATH" in
        .roomodes|.nova/*|.roo/*|README.md)
            DEST_PATH="$TARGET_DIR/$FILE_PATH"
            mkdir -p "$(dirname "$DEST_PATH")"
            echo " - Downloading: $FILE_PATH"
            curl -sSL -o "$DEST_PATH" "$RAW_URL_BASE/$FILE_PATH"
            ((DOWNLOAD_COUNT++))
            ;;
    esac
done

echo
echo -e "${GREEN}Installation complete! Downloaded $DOWNLOAD_COUNT files.${NC}"
echo -e "${GREEN}The Nova System files have been successfully installed into:${NC}"
echo "$TARGET_DIR"

exit 0