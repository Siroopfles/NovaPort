#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# This script runs all necessary formatters on the codebase.
# It's intended to be run locally by developers before committing.

# --- ANSI Colors for better output ---
RESET='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

echo -e "${YELLOW}--- Running Formatters ---${RESET}"

# --- 1. Formatting Markdown, YAML, Shell with Prettier ---
echo "Running Prettier..."
if [ ! -d "node_modules" ]; then
  echo "Node modules not found. Running 'npm install'..."
  npm install
fi
./node_modules/.bin/prettier --write .
echo -e "${GREEN}Prettier finished.${RESET}"
echo ""

# --- 2. Formatting Python code with isort and black ---
echo "Running isort to sort Python imports..."
isort .
echo -e "${GREEN}isort finished.${RESET}"
echo ""

echo "Running black to format Python code..."
black .
echo -e "${GREEN}black finished.${RESET}"
echo ""

echo -e "${GREEN}--- All formatters completed successfully! ---${RESET}"