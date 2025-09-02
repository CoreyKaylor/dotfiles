#!/bin/bash

# brew-backup.sh - Update Brewfile with current Homebrew packages
# This script helps maintain an up-to-date record of installed Homebrew packages

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Error: This script is for macOS only"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed"
    echo "Run ./install.sh to install Homebrew first"
    exit 1
fi

echo "Updating Brewfile with current Homebrew packages..."

# Create backup of existing Brewfile if it exists
if [ -f "Brewfile" ]; then
    cp Brewfile Brewfile.bak
    echo "Backed up existing Brewfile to Brewfile.bak"
fi

# Generate new Brewfile with descriptions
brew bundle dump --file=./Brewfile --force --describe

if [ $? -eq 0 ]; then
    echo "✓ Brewfile updated successfully"
    
    # Show statistics
    TAPS=$(grep -c "^tap " Brewfile 2>/dev/null || echo 0)
    BREWS=$(grep -c "^brew " Brewfile 2>/dev/null || echo 0)
    CASKS=$(grep -c "^cask " Brewfile 2>/dev/null || echo 0)
    
    echo ""
    echo "Package summary:"
    echo "  Taps:  $TAPS"
    echo "  Brews: $BREWS"
    echo "  Casks: $CASKS"
    echo ""
    echo "Don't forget to commit the updated Brewfile:"
    echo "  git add Brewfile"
    echo "  git commit -m 'Update Brewfile with current packages'"
else
    echo "Error: Failed to update Brewfile"
    # Restore backup if it exists
    if [ -f "Brewfile.bak" ]; then
        mv Brewfile.bak Brewfile
        echo "Restored previous Brewfile from backup"
    fi
    exit 1
fi