#!/usr/bin/env ruby

require 'optparse'
require 'json' # Require the JSON module for parsing JSON data

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: setup.rb [options]"

  opts.on('-f', '--force', "Force Homebrew to install, even if it is already installed") do |force|
    options[:force] = force
  end

  opts.on('-n', '--no-update', "Skip updating Homebrew to the latest version") do
    options[:no_update] = true
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

# Function to fetch the latest minor version of a package from Homebrew
def latest_minor_version(package_name)
  latest_version = `brew info --json=v1 #{package_name}`.lines.map do |line|
    JSON.parse(line)["versions"]
  end.flatten.select do |version|
    version.match?(/^\d+\.\d+\.\d+$/)
  end.max_by do |version|
    Gem::Version.new(version)
  end

  latest_version
end

# Function to install a package using Homebrew
def install_package(package_name, version = nil)
  if version.nil?
    version = latest_minor_version(package_name)
  end

  if version
    puts "Installing #{package_name}@#{version}..."
    system("brew install #{package_name}@#{version}")
  else
    puts "No suitable version found for #{package_name}."
  end
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
  unless options.key?(:no_update) && options[:no_update]
    update_homebrew
  else
    puts "Skipping update..."
  end

  # Install packages
  install_package('pyenv', '2.3.23')
  install_package('gh')
  install_package('coreutils')

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
