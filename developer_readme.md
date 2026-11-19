## Quick start

### 1. First-time setup (macOS)
# Check for Homebrew (required to install system tools cleanly on Mac)
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed."
    echo "Please install Homebrew first by running:"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

# Check & install Git 
echo "==> Step 1: Checking Git"
if ! command -v git &> /dev/null; then
     echo "Installing Git..."
     brew install git
fi

# Git clone 
git clone https://github.com/<your-username>/nl-labour-market-explorer.git
cd nl-labour-market-explorer

Run the prerequisites script **once** before working on the project to install Python 3, Poetry, and all project dependencies:

```bash
chmod +x prerequsites.sh
./prerequsites.sh
