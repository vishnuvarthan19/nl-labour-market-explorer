#!/usr/bin/env bash
#This File need to be removed in the final project
set -e

echo "=================================================="
echo "  NL Labour Market Explorer - macOS Setup (Poetry)"
echo "=================================================="

# 1. Verify macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "❌ This script is configured for macOS only."
    exit 1
fi

# 2. Check for Homebrew (required to install system tools cleanly on Mac)
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed."
    echo "Please install Homebrew first by running:"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

# 3. Check & install Git and Python 3
echo "==> Step 1: Checking Git and Python 3..."
if ! command -v git &> /dev/null; then
    echo "Installing Git..."
    brew install git
fi

if ! command -v python3 &> /dev/null; then
    echo "Installing Python 3..."
    brew install python
fi

# 4. Check & install Poetry FIRST
echo "==> Step 2: Checking and installing Poetry..."
if ! command -v poetry &> /dev/null; then
    echo "Installing Poetry..."
    curl -sSL https://install.python-poetry.org | python3 -
    export PATH="$HOME/.local/bin:$PATH"
    echo "✔ Poetry installed."
else
    echo "✔ Poetry is already installed ($(poetry --version))."
fi

# 5. Install Project Dependencies via Poetry
if [[ -f "pyproject.toml" ]]; then
    echo "==> Step 3: Installing project Python dependencies..."
    poetry install
    echo "✔ Project dependencies installed."
else
    echo "⚠️ pyproject.toml not found. Please create your pyproject.toml first."
fi

echo ""
echo "=================================================="
echo "  Setup complete! Your local Poetry environment is ready."
echo "=================================================="
