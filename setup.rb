#!/usr/bin/env ruby

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: setup.rb [options]"

  opts.on('-f', '--force', "Force Homebrew to install, even if it is already installed") do
    options[:force] = true
  end

  opts.on('-n', '--no-update', "Skip updating Homebrew to the latest version") do
    options[:no_update] = true
  end

  opts.on('-h', '--help', "Print all the available arguments") do
    puts opts
    exit
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

# Check if Homebrew is not installed or if the --force flag is provided
if !homebrew_installed? || options[:force]
  install_homebrew
else
  # Homebrew is already installed
  puts "Brew already installed... skipping installation"
end

# Update Homebrew to the latest version unless --no-update is specified
unless options[:no_update]
  puts "Updating Homebrew..."
  system('brew update')
else
  puts "Skipping update..."
end
