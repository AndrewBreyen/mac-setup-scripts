#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'json'
require 'logger'

LOG = Logger.new($stdout)
LOG.level = Logger::INFO # Set the desired log level (can be Logger::ERROR, Logger::WARN, Logger::INFO, Logger::DEBUG)

LOG.formatter = proc do |severity, _datetime, _progname, msg|
  "#{severity[0]} -- : #{msg}\n"
end

OPTIONS = {} # rubocop:disable Style/MutableConstant
OptionParser.new do |opts| # rubocop:disable Metrics/BlockLength
  opts.banner = 'Usage: setup.rb [options]'

  opts.on('-h', '--help', 'Print all the available arguments') do
    puts opts
    exit
  end

  opts.on('-f', '--force-homebrew', 'Force Homebrew to install, even if it is already installed') do
    OPTIONS[:force_homebrew_install] = true
  end

  opts.on('-n', '--no-homebrew-update', 'Skip updating Homebrew to the latest version') do
    OPTIONS[:no_homebrew_update] = true
  end

  opts.on('-d', '--dry-run', 'Run the script as dry-run. No changes will be made.') do
    OPTIONS[:dry_run] = true
  end

  opts.on('-c', '--force-pyenv-config', 'Force reinitialize pyenv') do
    OPTIONS[:force_pyenv] = true
  end

  opts.on('-o', '--skip-packages', 'Skip package installs') do
    OPTIONS[:skip_packages] = true
  end

  opts.on('-a', '--skip-casks', 'Skip cask installs') do
    OPTIONS[:skip_casks] = true
  end

  opts.on('-y', '--skip-python', 'Skip python install') do
    OPTIONS[:skip_pyenv_python_install] = true
  end

  opts.on('-r', '--force-python-install',
          'Force installation of the latest stable Python even if it is already installed') do
    OPTIONS[:force_python_install] = true
  end
end.parse!

# Function to check if Homebrew is installed
def homebrew_installed?
  system('command -v brew > /dev/null')
end

# Function to install Homebrew
# Check if Homebrew is not installed or if the --force flag is provided
def install_homebrew
  if homebrew_installed? || OPTIONS[:force_homebrew_install]
    # Homebrew is already installed
    LOG.info 'Homebrew already installed... Skipping installation'
  else
    LOG.info 'Installing Homebrew...'
    system('export HOMEBREW_NO_INSTALL_FROM_API=1')
    system('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
  end
end

# Function to update Homebrew
def update_homebrew
  # Update Homebrew to the latest version unless --no-update is specified
  if OPTIONS[:no_homebrew_update]
    LOG.info 'Skipping Homebrew update...'
  else
    LOG.info 'Updating Homebrew...'
    system('brew update')
  end
end

# Function to configure pyenv
def configure_pyenv(force: false)
  # Configure pyenv if not already configured or force_pyenv option is provided
  if OPTIONS[:force_pyenv] || !pyenv_configured?
    update_shell_profile(force)
    source_shell_profile
  else
    LOG.info 'pyenv is already configured.'
  end
end

# Function to update the shell profile with pyenv initialization
def update_shell_profile(force)
  shell_profile = File.expand_path('~/.zshrc') # Use .zshrc for Zsh
  if pyenv_already_configured?(shell_profile) && !force
    LOG.info "pyenv is already configured in #{shell_profile}."
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
  LOG.info "Added pyenv initialization to #{shell_profile}."
end

# Function to source the shell profile to apply the changes
def source_shell_profile
  shell_profile = File.expand_path('~/.zshrc') # Use .zshrc for Zsh
  return false unless File.exist?(shell_profile)

  system("source #{shell_profile}")
end

# Function to check if pyenv is already configured in the shell profile
def pyenv_configured?
  shell_profile = File.expand_path('~/.zshrc') # Use .zshrc for Zsh
  return false unless File.exist?(shell_profile)

  File.read(shell_profile).include?('pyenv init')
end

# Function to install a package using Homebrew
def install_package(package_name)
  # Install packages unless skip_packages option is provided
  if OPTIONS[:skip_packages]
    LOG.info "Skipping #{package_name} package install..."
  else
    LOG.info "Installing package #{package_name}..."
    system("brew install #{package_name} -q")
  end
end

# Function to install a cask using Homebrew
def install_cask(cask_name)
  if OPTIONS[:skip_casks]
    LOG.info 'Skipping cask installs...'
  else
    LOG.info "Installing cask #{cask_name}..."
    system("brew install --cask #{cask_name} -q")
  end
end

# Function to install the latest stable version of Python using pyenv
def install_python_with_pyenv
  if OPTIONS[:skip_pyenv_python_install]
    LOG.info 'Skipping python install...'
  else
    do_python_install
  end
end

def do_python_install
  latest_version = `pyenv install --list | grep -v - | grep -E "^\s*?[0-9\.]+$" | tail -1`.strip
  installed_versions = `pyenv versions --bare`.split

  if installed_versions.include?(latest_version) && !OPTIONS[:force_python_install]
    LOG.info "Python #{latest_version} is already installed using pyenv. Skipping installation."
  else
    LOG.info "Installing the latest stable version of Python (#{latest_version}) using pyenv..."
    system("yes | pyenv install #{latest_version}")
    LOG.info 'Python installation completed.'
  end
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

install_homebrew
update_homebrew

# Install packages
install_package('pyenv')
install_package('gh')
install_package('coreutils')

# Install casks
install_cask('spotify')
install_cask('postman')
install_cask('visual-studio-code')
install_cask('authy')

# Configure pyenv
configure_pyenv
install_python_with_pyenv

# Custom completion message
puts <<~BANNER
  #####
  #####
  ##### Mac Setup Completed successfully
  #####
BANNER
