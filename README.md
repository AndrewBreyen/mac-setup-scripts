# Mac Setup Script

This script is designed to automate the setup process for a new Mac system. It uses Homebrew to install and update packages and can also configure `pyenv` and other tools.

[![Lint using Rubocop](https://github.com/AndrewBreyen/mac-setup-scripts/actions/workflows/lint.yml/badge.svg?branch=main)](https://github.com/AndrewBreyen/mac-setup-scripts/actions/workflows/lint.yml)

## Requirements

- Ruby (tested on Ruby 2.6.10)

## Usage

Run the script using the following command:

```
ruby setup2.rb [options]
```

### Options

- `-h, --help`: Print all the available arguments
- `-f, --force`: Force Homebrew to install, even if it is already installed
- `-n, --no-update`: Skip updating Homebrew to the latest version
- `-d, --dry-run`: Run the script as dry-run. No changes will be made.
- `-c, --force-pyenv-config`: Force reinitialize pyenv
- `-o, --skip-packages`: Skip package installs