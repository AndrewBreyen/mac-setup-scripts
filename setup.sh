#!/bin/bash

# Check if Homebrew is not installed or if the --force flag is provided
if ! command -v brew &> /dev/null || [ "$1" = "--force" ]; then
    # Install homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    # Homebrew is already installed
    echo "Brew already installed... skipping installation"
fi

# Update Homebrew to the latest version
brew update
