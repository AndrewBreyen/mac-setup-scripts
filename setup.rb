#!/usr/bin/env ruby

require 'optparse'
require 'json'
require 'pry'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: setup.rb [options]"

  opts.on('-h', '--help', "Print all the available arguments") do
    puts opts
    exit
  end

  opts.on('-f', '--force', "Force Homebrew to install, even if it is already installed") do 
    options[:force] = true
  end

  opts.on('-n', '--no-update', "Skip updating Homebrew to the latest version") do
    options[:no_update] = true
  end

  opts.on('-d', '--dry-run', "Run the script as dry-run. No changes will be made.") do
    options[:dry_run] = true
  end

  # New option to force reinitialization of pyenv with short argument -c
  opts.on('-c', '--force-pyenv-config', "Force reinitialize pyenv") do
    options[:force_pyenv] = true
  end

  # New option to skip package installs with short argument -o
  opts.on('-o', '--skip-packages', "Skip package installs") do
    options[:skip_packages] = true
  end

end.parse!

# Function to check if Homebrew is installed
def homebrew_installed?
  system('command -v brew > /dev/null')
end

# Function to install Homebrew
def install_homebrew
  puts "Installing Homebrew..."
  system('export HOMEBREW_NO_INSTALL_FROM_API=1')
  system('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
end

# Function to update Homebrew
def update_homebrew
  puts "Updating Homebrew..."
  system('brew update')
end

# Function to configure pyenv
def configure_pyenv(force = false)
  # Add pyenv initialization to your shell profile (e.g., .bashrc or .zshrc)
  # Note: You may need to adjust this depending on the shell you use.
  shell_profile = File.expand_path("~/.zshrc") # Use .zshrc for Zsh
  unless File.read(shell_profile).include?("pyenv init") && !force
    File.open(shell_profile, "a") do |file|
      file.puts("# Initialize pyenv")
      file.puts('eval "$(pyenv init --path)"')
      file.puts('eval "$(pyenv virtualenv-init -)"')
    end
    puts "Added pyenv initialization to #{shell_profile}."
  else
    puts "pyenv is already configured in #{shell_profile}."
  end

  # Source the shell profile to apply the changes to the current terminal session
  system("source #{shell_profile}")
end

# Function to check if pyenv is already configured in the shell profile
def pyenv_configured?
  shell_profile = File.expand_path("~/.zshrc") # Use .zshrc for Zsh
  File.read(shell_profile).include?("pyenv init")
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

# Runner method to execute all the commands
def run_setup(options)
  # Custom welcome banner
  puts <<~BANNER
    #####
    #####
    ##### Mac Setup
    #####

  BANNER

  # Check if Homebrew is not installed or if the --force flag is provided
  unless homebrew_installed? || options[:force]
    install_homebrew
  else
    # Homebrew is already installed
    puts "Brew already installed... skipping installation"
  end

  # Update Homebrew to the latest version unless --no-update is specified
  unless options[:no_update]
    update_homebrew
  else
    puts "Skipping update..."
  end

  # Install packages unless skip_packages option is provided
  unless options[:skip_packages]
    install_package('pyenv')
    install_package('gh')
    install_package('coreutils')
  else
    puts "Skipping package installs..."
  end

  unless options[:skip_casks]
    install_cask('spotify')
  else
    puts "Skipping package installs..."
  end

  # Configure pyenv if not already configured or force_pyenv option is provided
  if options[:force_pyenv] || !pyenv_configured?
    configure_pyenv
  else
    puts "pyenv is already configured."
  end

  # Custom completion message
  puts <<~BANNER
    #####
    #####
    ##### Mac Setup Completed successfully
    #####
    
  BANNER
end

# Call the runner method to execute all the commands
run_setup(options)
