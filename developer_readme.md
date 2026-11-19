## Quick start

### 1. First-time setup (macOS)
# Command to install brew in Mac
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Command to install Git 
brew install git

# Git clone 
git clone https://github.com/<your-username>/nl-labour-market-explorer.git
cd nl-labour-market-explorer

Run the prerequisites script **once** before working on the project to install Python 3, Poetry, and all project dependencies:

```bash
chmod +x prerequsites.sh
./prerequsites.sh
