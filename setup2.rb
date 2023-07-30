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

  opts.on('-o', '--no-homebrew-update', "Skip updating Homebrew to the latest version") do
    options[:no_homebrew_update] = true
  end

  opts.on('-a', '--no-package-update', "Skip updating Homebrew to the latest version") do
    options[:no_package_update] = true
  end



  opts.on('-d', '--dry-run', "Run the script as dry-run. No changes will be made.") do
    options[:dry_run] = true
  end

  #############
  # not working properly
  #############
  opts.on('-p', '--force-pyenv', "Force reinitialize pyenv") do
    options[:force_pyenv] = true
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

# # Function to fetch the latest minor version of a package from Homebrew
# def latest_minor_version(package_name)
#   latest_version = `brew list --versions #{package_name}`.lines.map do |line|
#     line.match(/#{package_name}@(\d+\.\d+\.\d+)/)&.captures&.first
#   end.compact.select do |version|
#     version.match?(/^\d+\.\d+\.\d+$/)
#   end.max_by do |version|
#     Gem::Version.new(version)
#   end

#   latest_version
# end

# # Function to install a package using Homebrew
# def install_package(package_name, version = nil)
#   # binding.pry
#   if version.nil?
#     version = latest_minor_version(package_name)
#   end

#   if version
#     puts "Installing #{package_name}@#{version}..."
#     system("brew install #{package_name}@#{version}")
#   else
#     puts "No suitable version found for #{package_name}."
#   end
# end


def install_package(package_name)
  puts "Installing #{package_name}..."
  system("brew install #{package_name} -q")
end













# # Runner method to execute all the commands
# def run_setup(options)
# Custom welcome banner
puts <<~BANNER
  #####
  ##### Mac Setup
  #####

BANNER

# Check if Homebrew is not installed or if the --force flag is provided
puts
puts "Installing brew..."
unless homebrew_installed? || options[:force]
  install_homebrew
else
  # Homebrew is already installed
  puts "Brew already installed... skipping installation"
end


# Update Homebrew to the latest version unless --no-update is specified
puts
puts "Updating brew..."
unless options[:no_homebrew_update]
  update_homebrew
else
  puts "Skipping update..."
end


# Update Homebrew to the latest version unless --no-update is specified
puts
puts "Installing packages..."
unless options[:no_package_update]
  install_package('pyenv')
  install_package('gh')
  install_package('coreutils')
else
  puts "Skipping package installs..."
end


# Configure pyenv if not already configured or force_pyenv option is provided
puts
puts "Configuring pyenv..."
if options[:force_pyenv] || !pyenv_configured?
  configure_pyenv
else
  puts "pyenv is already configured."
end



  # Install packages
  install_package('pyenv')
  install_package('gh')
  install_package('coreutils')

# Custom completion message
puts <<~BANNER

  #####
  ##### Mac Setup Completed successfully
  #####
  
BANNER
# end

# Call the runner method to execute all the commands
run_setup(options)
