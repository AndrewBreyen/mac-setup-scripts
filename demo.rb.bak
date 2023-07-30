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
    install_package('markdownlint')
  
    # Completion message indicating the script has finished
    puts "========================================================================"
    puts "                Setup Completed Successfully!                           "
    puts "========================================================================"
  end
  
  # Call the runner method to execute all the commands
  run_setup(options)
  