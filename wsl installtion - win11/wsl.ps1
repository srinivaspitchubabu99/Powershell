# PowerShell script to install WSL and select a distribution

# Check if the script is running with administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an administrator." -ForegroundColor Red
    exit
}

# Enable WSL feature
Write-Host "Enabling Windows Subsystem for Linux..."
wsl --install

# Set WSL version to 2
Write-Host "Setting WSL version to 2..."
wsl --set-default-version 2

# List available distributions
Write-Host "Available Linux distributions:"
$distributions = wsl --list --online
Write-Host $distributions

# Prompt user for distribution selection
$selectedDistro = Read-Host "Enter the name of the distribution you want to install (e.g., Ubuntu, Debian, etc.)"

# Install the selected distribution
Write-Host "Installing $selectedDistro..."
wsl --install -d $selectedDistro

Write-Host "WSL installation completed. Please restart your computer."
