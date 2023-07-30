#!/bin/bash



# Function to check if Homebrew is installed
check_brew_installed() {
    if ! command -v brew &>/dev/null; then
        return 1
    else
        return 0
    fi
}

# Install Homebrew if not already installed
install_brew() {
    if ! check_brew_installed; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Install gh (GitHub CLI) using Homebrew
install_gh() {
    if check_brew_installed; then
        echo "Installing GitHub CLI (gh) using Homebrew..."
        brew install gh
    else
        echo "Homebrew is not installed. Cannot install gh."
        exit 1
    fi
}

# Install Pyenv using Homebrew
install_pyenv() {
    if check_brew_installed; then
        echo "Installing Pyenv using Homebrew..."
        brew update
        brew install pyenv
        echo 'eval "$(pyenv init --path)"' >> ~/.bash_profile
        echo 'eval "$(pyenv init -)"' >> ~/.bashrc
        exec $SHELL
    else
        echo "Homebrew is not installed. Cannot install Pyenv."
        exit 1
    fi
}

# Install required Python dependencies using Homebrew
install_python_dependencies() {
    if check_brew_installed; then
        echo "Installing Python dependencies using Homebrew..."
        brew install openssl readline sqlite3 xz zlib tcl-tk
    else
        echo "Error: Cannot install Python dependencies."
        exit 1
    fi
}


# Function to check if Homebrew is installed
install_vercel() {
    if ! command -v brew &>/dev/null; then
        return 1
    else
        return 0
    fi
}



# Main script execution
install_brew
install_gh
install_pyenv
install_python_dependencies
# install vercel

echo "Provisioning completed successfully."
