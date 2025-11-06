#!/bin/bash

set -euo pipefail

plain_file=/passwd/mosquitto.plain
passwd_file=/passwd/mosquitto.passwd

# Password length configuration (in bytes, base64 encoded)
# Default: 32 bytes = 256 bits of entropy
# Range: 16-128 bytes (128-1024 bits)
PASSWORD_LENGTH="${PASSWORD_LENGTH:-32}"

# Validate password length
validate_password_length()
{
  if ! [[ "$PASSWORD_LENGTH" =~ ^[0-9]+$ ]]; then
    echo "Error: PASSWORD_LENGTH must be a number. Got: '$PASSWORD_LENGTH'" >&2
    exit 1
  fi

  if [ "$PASSWORD_LENGTH" -lt 16 ]; then
    echo "Error: PASSWORD_LENGTH must be at least 16 bytes (got $PASSWORD_LENGTH)." >&2
    echo "Hint: Use PASSWORD_LENGTH=16 or higher for security." >&2
    exit 1
  fi

  if [ "$PASSWORD_LENGTH" -gt 128 ]; then
    echo "Error: PASSWORD_LENGTH must be at most 128 bytes (got $PASSWORD_LENGTH)." >&2
    exit 1
  fi
}

# Validate username for security
validate_username()
{
  local username=$1

  # Check if username is empty
  if [ -z "$username" ]; then
    echo "Error: Username cannot be empty." >&2
    return 1
  fi

  # Check username length (max 64 characters)
  if [ ${#username} -gt 64 ]; then
    echo "Error: Username '$username' is too long (max 64 characters)." >&2
    return 1
  fi

  # Only allow alphanumeric characters, underscore, hyphen, and dot
  if ! [[ "$username" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: Username '$username' contains invalid characters. Only alphanumeric, underscore, hyphen, and dot are allowed." >&2
    return 1
  fi

  return 0
}

# Check if required commands are available
check_dependencies()
{
  local missing_deps=()

  for cmd in openssl mosquitto_passwd; do
    if ! command -v "$cmd" &> /dev/null; then
      missing_deps+=("$cmd")
    fi
  done

  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "Error: Missing required dependencies: ${missing_deps[*]}" >&2
    exit 1
  fi
}

# Check if /passwd directory is writable
check_passwd_dir()
{
  if [ ! -d "/passwd" ]; then
    echo "Error: /passwd directory does not exist. Please mount a volume to /passwd." >&2
    exit 1
  fi

  if [ ! -w "/passwd" ]; then
    echo "Error: /passwd directory is not writable." >&2
    exit 1
  fi
}

add_user_passwd()
{
  local username=$1

  # Validate username
  if ! validate_username "$username"; then
    echo "Skipping invalid username: '$username'" >&2
    return 1
  fi

  echo "Generating password for '$username' (length: ${PASSWORD_LENGTH} bytes)."

  # Generate password
  local passwd
  if ! passwd=$(openssl rand -base64 "$PASSWORD_LENGTH"); then
    echo "Error: Failed to generate password for '$username'." >&2
    return 1
  fi

  local json_file=/passwd/"${username}"_passwd.json
  echo "Saving username and plain-text password to '$json_file'."

  # Create JSON file with secure permissions
  if ! echo -e "{\n  \"Username\":\"${username}\",\n  \"Password\":\"${passwd}\"\n}\n" > "$json_file"; then
    echo "Error: Failed to write to '$json_file'." >&2
    return 1
  fi
  chmod 600 "$json_file"

  echo "Appending username and plain-text password to '$plain_file'."
  if ! echo "$username:$passwd" >> "$plain_file"; then
    echo "Error: Failed to write to '$plain_file'." >&2
    return 1
  fi

  # Securely clear password from memory
  passwd="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  unset passwd

  return 0
}

# Validate configuration and environment
validate_password_length
check_dependencies
check_passwd_dir

# Display configuration
echo "Configuration:"
echo "  Password length: ${PASSWORD_LENGTH} bytes"
echo ""

if [ $# -eq 0 ]; then
  username="user"
  if ! add_user_passwd "$username"; then
    echo "Error: Failed to add default user." >&2
    exit 1
  fi
else
  echo "Generating passwords for users: $*"
  failed_users=()

  for username in "$@"; do
    if ! add_user_passwd "$username"; then
      failed_users+=("$username")
    fi
  done

  if [ ${#failed_users[@]} -gt 0 ]; then
    echo "Warning: Failed to process the following users: ${failed_users[*]}" >&2
  fi
fi

echo "Encrypting plain-text password using mosquitto_passwd."
if ! cp "$plain_file" "$passwd_file"; then
  echo "Error: Failed to copy '$plain_file' to '$passwd_file'." >&2
  exit 1
fi

if ! mosquitto_passwd -U "$passwd_file"; then
  echo "Error: Failed to encrypt password file." >&2
  exit 1
fi

echo "Contents of '$passwd_file':"
cat "$passwd_file"

# Set secure permissions (owner read/write only)
chmod 600 "$plain_file"
chmod 600 "$passwd_file"

echo ""
echo "WARNING: Plain-text passwords are stored in '$plain_file' and individual JSON files."
echo "These files contain sensitive information. Ensure proper access controls are in place."
