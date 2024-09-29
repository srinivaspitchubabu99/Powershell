# Function to get the OS version and validate if it's Windows 10, 11, or Server
function Get-OSVersion {
    $version = (Get-CimInstance Win32_OperatingSystem).Version
    Write-Host "Detected OS version: $version"

    # Detect Windows 11 (including Insider Preview)
    if ($version -like "10.0.22*") {
        Write-Host "Windows 11 detected."
        return "Windows11"
    }
    # Detect Windows 10
    elseif ($version -like "10.0.19041*" -or $version -like "10.0.18362*") {
        Write-Host "Windows 10 detected."
        return "Windows10"
    }
    # Detect Windows Server
    elseif ($version -like "10.0.17763*" -or $version -like "10.0.14393*") {
        Write-Host "Windows Server detected."
        return "WindowsServer"
    } else {
        Write-Host "Unsupported OS version."
        return "Unsupported"
    }
}

# Function to enable WSL if it's not already installed
function Enable-WSL {
    Write-Host "Checking if WSL is already enabled..."
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

    if ($wslFeature.State -eq "Enabled") {
        Write-Host "WSL is already enabled."
    } else {
        Write-Host "Enabling WSL..."
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop
    }
}

# Function to enable Virtual Machine Platform (required for WSL 2)
function Enable-VirtualMachinePlatform {
    Write-Host "Enabling Virtual Machine Platform..."
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction Stop
}

# Function to disable WSL if it's installed
function Disable-WSL {
    Write-Host "Disabling WSL..."
    Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Write-Host "WSL has been disabled. You may need to restart your system."
}

# Function to disable Virtual Machine Platform if it's enabled
function Disable-VirtualMachinePlatform {
    Write-Host "Disabling Virtual Machine Platform..."
    Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    Write-Host "Virtual Machine Platform has been disabled."
}

# Function to remove WSL and all distributions
function Remove-WSL {
    $osType = Get-OSVersion

    if ($osType -eq "Unsupported") {
        Write-Host "Exiting the script as the OS is not supported."
        exit
    }

    Disable-WSL
    Disable-VirtualMachinePlatform

    # Uninstall WSL Kernel update package (only for Windows 10 and 11)
    if ($osType -eq "Windows10" -or $osType -eq "Windows11") {
        Write-Host "Uninstalling WSL kernel update..."
        wsl --uninstall
    }

    # Ask user if they want to remove all installed Linux distributions
    $removeDistros = Read-Host "Do you want to remove all installed Linux distributions? (Y/N)"
    
    if ($removeDistros -eq "Y") {
        wsl --unregister Ubuntu
        wsl --unregister Debian
        wsl --unregister Kali-Linux
        wsl --unregister SUSE
        wsl --unregister OpenSUSE-Leap
        Write-Host "All Linux distributions have been uninstalled."
    } else {
        Write-Host "Linux distributions were not uninstalled."
    }

    Write-Host "WSL and its features have been removed. Please restart your system to apply changes."
}

# Function to install WSL and the user-selected distribution
function Install-WSL {
    $osType = Get-OSVersion

    if ($osType -eq "Unsupported") {
        Write-Host "Exiting the script as the OS is not supported."
        exit
    }

    Enable-WSL
    Enable-VirtualMachinePlatform

    # Install the Linux kernel update package if needed (Windows 10, Windows 11)
    if ($osType -eq "Windows10" -or $osType -eq "Windows11") {
        wsl --update
    }

    # Ask user for the Linux distribution to install
    $distros = @("Ubuntu", "Debian", "Kali-Linux", "SUSE", "OpenSUSE-Leap")
    $selectedDistro = Read-Host "Select the Linux distribution to install: (Options: Ubuntu, Debian, Kali-Linux, SUSE, OpenSUSE-Leap)"

    if ($distros -contains $selectedDistro) {
        Write-Host "Installing $selectedDistro..."
        wsl --install -d $selectedDistro
    } else {
        Write-Host "Invalid selection. Please select a valid distribution."
        exit
    }

    Write-Host "Installation completed. Please restart your system to apply changes."
}

# Main function to ask for user action: Install or Remove
function Main {
    $action = Read-Host "Do you want to install or remove WSL? (Options: Install, Remove)"
    
    if ($action -eq "Install") {
        Install-WSL
    } elseif ($action -eq "Remove") {
        Remove-WSL
    } else {
        Write-Host "Invalid selection. Please select 'Install' or 'Remove'."
        exit
    }
}

# Start the process
Main
