#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Define variables
DOPSCTL_DIR="/var/dopsctl"
REPO_URL="https://github.com/khushalchandak17/dopsctl.git"

# Fetch a writable directory from $PATH
BIN_DIR=$(echo "$PATH" | tr ':' '\n' | grep -m 1 "/usr/local/bin")

# Fallback if no suitable directory is found
if [ -z "$BIN_DIR" ]; then
  echo "No suitable directory found in \$PATH. Falling back to /usr/local/bin."
  BIN_DIR="/usr/local/bin"
fi

SYMLINK_PATH="$BIN_DIR/dopsctl"

# Step 1: Remove the existing directory (if any)
if [ -d "$DOPSCTL_DIR" ]; then
  echo "Removing existing directory: $DOPSCTL_DIR"
  rm -rf "$DOPSCTL_DIR"
fi

# Step 2: Create the directory
echo "Creating directory: $DOPSCTL_DIR"
mkdir -p "$DOPSCTL_DIR"

# Step 3: Clone the GitHub repository
echo "Cloning repository from $REPO_URL to $DOPSCTL_DIR"
git clone "$REPO_URL" "$DOPSCTL_DIR"

# Step 4: Create a symlink in $PATH
if [ -L "$SYMLINK_PATH" ]; then
  echo "Removing existing symlink: $SYMLINK_PATH"
  rm -f "$SYMLINK_PATH"
fi

# Ensure the target file is executable
if [ -f "$DOPSCTL_DIR/dopsctl" ]; then
  chmod +x "$DOPSCTL_DIR/dopsctl"
else
  echo "Error: The file $DOPSCTL_DIR/dopsctl does not exist." >&2
  exit 1
fi

echo "Creating symlink: $SYMLINK_PATH -> $DOPSCTL_DIR/dopsctl"
ln -s "$DOPSCTL_DIR/dopsctl" "$SYMLINK_PATH"

# Step 5: Verify installation
if [ -L "$SYMLINK_PATH" ] && [ -x "$SYMLINK_PATH" ]; then
  echo "Installation completed successfully."
  echo "You can now use 'dopsctl' as root."
else
  echo "Error: Symlink creation failed or dopsctl is not executable." >&2
  exit 1
fi

## Clean this one
chmod +x -R /var/dopsctl/*

