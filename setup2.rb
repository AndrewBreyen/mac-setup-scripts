#!/usr/bin/env ruby

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: setup.rb [options]"

  opts.on('-f', '--force', "Force Homebrew to install, even if it is already installed") do |force|
    options[:force] = force
  end

  opts.on('-n', '--no-update', "Skip updating Homebrew to the latest version") do |no_update|
    options[:no_update] = no_update
  end

  opts.on('-h', '--help', "Print all the available arguments") do
    puts opts
    exit
  end

  opts.on('-d', '--dry-run', "Run the script as dry-run. No changes will be made.") do |force|
    options[:force] = force
  end

end.parse!

# Function to check if Homebrew is installed
def homebrew_installed?
  system('command -v brew > /dev/null')
end

# Function to install Homebrew
def install_homebrew
  puts "Installing Homebrew..."
  system('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
end

# Function to update Homebrew
def update_homebrew
  puts "Updating Homebrew..."
  system('brew update')
end

# Function to install a package using Homebrew
def install_package(package_name)
  puts "Installing #{package_name}..."
  system("brew install #{package_name}")
end

# Runner method to execute all the commands
def run_setup(options)
  # Large banner indicating the script is starting
  puts "========================================================================"
  puts "                  Welcome to the Setup Script                            "
  puts "========================================================================"

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

  # Install packages
  install_package('pyenv')
  install_package('gh')
  install_package('coreutils')
  
  

  # Completion message indicating the script has finished
  puts "========================================================================"
  puts "                Setup Completed Successfully!                           "
  puts "========================================================================"
end

# Call the runner method to execute all the commands
run_setup(options)
