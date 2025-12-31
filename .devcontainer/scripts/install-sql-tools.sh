#!/bin/bash
set -e

echo "Installing SQL Server tools..."

# Install prerequisites
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y curl apt-transport-https gnupg

# Add Microsoft package repository
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

# Install SQL Server tools
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev
sudo ACCEPT_EULA=Y apt-get install -y mssql-tools18

# Add sqlcmd to PATH for current user
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.zshrc

# Make sure it's available in current session
export PATH="$PATH:/opt/mssql-tools18/bin"

echo "SQL Server tools installed successfully!"
echo "sqlcmd is now available. You may need to restart your shell or run:"
echo "  source ~/.bashrc"
