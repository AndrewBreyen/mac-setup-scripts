#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'json'
require 'pry'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: setup.rb [options]'

  opts.on('-h', '--help', 'Print all the available arguments') do
    puts opts
    exit
  end

  opts.on('-f', '--force', 'Force Homebrew to install, even if it is already installed') do
    options[:force] = true
  end

  opts.on('-n', '--no-update', 'Skip updating Homebrew to the latest version') do
    options[:no_update] = true
  end

  opts.on('-d', '--dry-run', 'Run the script as dry-run. No changes will be made.') do
    options[:dry_run] = true
  end

  # New option to force reinitialization of pyenv with short argument -c
  opts.on('-c', '--force-pyenv-config', 'Force reinitialize pyenv') do
    options[:force_pyenv] = true
  end

  # New option to skip package installs with short argument -o
  opts.on('-o', '--skip-packages', 'Skip package installs') do
    options[:skip_packages] = true
  end
end.parse!

# Function to check if Homebrew is installed
def homebrew_installed?
  system('command -v brew > /dev/null')
end

# Function to install Homebrew
def install_homebrew
  puts 'Installing Homebrew...'
  system('export HOMEBREW_NO_INSTALL_FROM_API=1')
  system('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
end

# Function to update Homebrew
def update_homebrew
  puts 'Updating Homebrew...'
  system('brew update')
end

# Function to configure pyenv
def configure_pyenv(force: false)
  update_shell_profile(force)
  source_shell_profile
end

# Function to update the shell profile with pyenv initialization
def update_shell_profile(force)
  shell_profile = File.expand_path('~/.zshrc') # Use .zshrc for Zsh
  if pyenv_already_configured?(shell_profile) && !force
    puts "pyenv is already configured in #{shell_profile}."
  else
    add_pyenv_to_shell_profile(shell_profile)
  end
end

# Function to check if pyenv is already configured in the shell profile
def pyenv_already_configured?(shell_profile)
  File.read(shell_profile).include?('pyenv init')
end

# Function to add pyenv initialization to the shell profile
def add_pyenv_to_shell_profile(shell_profile)
  File.open(shell_profile, 'a') do |file|
    file.puts('# Initialize pyenv')
    file.puts('eval "$(pyenv init --path)"')
    file.puts('eval "$(pyenv virtualenv-init -)"')
  end
  puts "Added pyenv initialization to #{shell_profile}."
end

# Function to source the shell profile to apply the changes
def source_shell_profile
  shell_profile = File.expand_path('~/.zshrc') # Use .zshrc for Zsh
  system("source #{shell_profile}")
end

# Function to check if pyenv is already configured in the shell profile
def pyenv_configured?
  shell_profile = File.expand_path('~/.zshrc') # Use .zshrc for Zsh
  File.read(shell_profile).include?('pyenv init')
end

# Function to install a package using Homebrew
def install_package(package_name)
  puts "Installing #{package_name}..."
  system("brew install #{package_name} -q")
end

# Function to install a cask using Homebrew
def install_cask(cask_name)
  puts "Installing #{cask_name}..."
  system("brew install --cask #{cask_name} -q")
end

#########################
# RUN                   #
#########################
puts <<~BANNER
  #####
  #####
  ##### Mac Setup
  #####
BANNER

# Check if Homebrew is not installed or if the --force flag is provided
if homebrew_installed? || options[:force]
  # Homebrew is already installed
  puts 'Brew already installed... skipping installation'
else
  install_homebrew
end

# Update Homebrew to the latest version unless --no-update is specified
if options[:no_update]
  puts 'Skipping update...'
else
  update_homebrew
end

# Install packages unless skip_packages option is provided
if options[:skip_packages]
  puts 'Skipping package installs...'
else
  install_package('pyenv')
  install_package('gh')
  install_package('coreutils')
end

if options[:skip_casks]
  puts 'Skipping package installs...'
else
  install_cask('spotify')
end

# Configure pyenv if not already configured or force_pyenv option is provided
if options[:force_pyenv] || !pyenv_configured?
  configure_pyenv
else
  puts 'pyenv is already configured.'
end

# Custom completion message
puts <<~BANNER
  #####
  #####
  ##### Mac Setup Completed successfully
  #####
BANNER
