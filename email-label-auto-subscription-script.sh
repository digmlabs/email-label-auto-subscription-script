#!/bin/bash

# ------------------------------------------------------------
# Script Name: email-label-auto-subscription-script.sh
# Author: Karanbir Singh | DigmLabs.com
# Maintainers: Karanbir Singh (DigmLabs.com)
# Version: 1.0
# Description: 
# This script automatically scans for user-created mail folders
# in the Maildir structure of specified email accounts. It adds
# those folders to the user's 'subscriptions' file so they are
# auto-subscribed in IMAP clients. The script also cleans up
# any old folder entries in the 'subscriptions' file that no
# longer exist in the Maildir. It excludes default folders like
# Archive, Sent, Drafts, Junk, Spam, and Trash, which are 
# already subscribed by default in the Dovecot settings.
# The 'V       2' version line (with multiple spaces) and the empty second line 
# are ignored during processing. The script processes from the third line if these 
# are present; otherwise, it starts from the first line.
# After modifying the 'subscriptions' file, the script restores both the original ownership 
# and permissions of the file.
#
# Usage:
# Run this script with sudo privileges to ensure the changes 
# are applied across the user's Maildir directories.
# ------------------------------------------------------------

# Define the base mail directory (adjusted based on the correct path)
MAIL_DIR_BASE="/home"

# List of email addresses by domain
emails=(
  "test@example.com"
)

# List of folders to exclude from deletion and subscriptions
default_folders=("Archive" "Drafts" "Junk" "Sent" "Spam" "Trash" "spam")

# Function to determine the start point for file processing
get_start_line() {
    subscriptions_file="$1"

    # Check if the first line contains "V       2" (with multiple spaces) and the second line is empty
    first_line=$(head -n 1 "$subscriptions_file")
    second_line=$(sed -n '2p' "$subscriptions_file")

    if [[ "$first_line" == "V       2" ]] && [[ "$second_line" == "" ]]; then
        echo 3  # Start processing from the third line
    else
        echo 1  # Start processing from the first line
    fi
}

# Loop through each email
for email in "${emails[@]}"; do
  # Extract local part and domain from the email
  local_part=$(echo "$email" | cut -d '@' -f 1)
  full_domain=$(echo "$email" | cut -d '@' -f 2)

  # Extract the part of the domain before the dot
  domain=$(echo "$full_domain" | cut -d '.' -f 1)

  # Define the user's Maildir location (based on the correct path)
  maildir_path="$MAIL_DIR_BASE/$domain/mail/$full_domain/$local_part"

  # Check if the directory exists
  if [ -d "$maildir_path" ]; then
    echo "Processing $email in $maildir_path"

    # Navigate to the Maildir
    cd "$maildir_path" || continue

    # Ensure that the subscriptions file is checked correctly
    subscriptions_file="$maildir_path/subscriptions"

    # Capture the current ownership and permissions of the subscriptions file (if it exists)
    if [ -f "$subscriptions_file" ]; then
      original_owner=$(stat -c '%U:%G' "$subscriptions_file")
      original_permissions=$(stat -c '%a' "$subscriptions_file")
    else
      original_owner="$domain:$domain"  # Default to domain owner if the file doesn't exist
      original_permissions="640"        # Default permissions
    fi

    # Get the line number to start processing the subscriptions file
    start_line=$(get_start_line "$subscriptions_file")

    # Clean up: Remove entries from subscriptions if the folder no longer exists and is not in the default_folders array
    if [ -f "$subscriptions_file" ]; then
      # Create a temporary file to store updated subscriptions
      temp_subs=$(mktemp)
      
      # If the file starts with "V       2" and has an empty second line, preserve them
      if [ "$start_line" -eq 3 ]; then
        head -n 2 "$subscriptions_file" > "$temp_subs"
      fi

      # Skip non-existent folders in the subscriptions file but keep default folders
      tail -n +$start_line "$subscriptions_file" | while IFS= read -r folder_name; do
        # Check if the folder exists or is in the default folder list
        if [ -d ".$folder_name" ] || [[ " ${default_folders[@]} " =~ " $folder_name " ]]; then
          echo "$folder_name" >> "$temp_subs"
        else
          echo "Removing non-existent folder: $folder_name from $subscriptions_file"
        fi
      done

      # Move the updated content back to the subscriptions file
      mv "$temp_subs" "$subscriptions_file"

      # Restore the original ownership and permissions of the subscriptions file
      chown "$original_owner" "$subscriptions_file"
      chmod "$original_permissions" "$subscriptions_file"
    fi

    # List all folders (those starting with a dot) and add them to subscriptions
    for folder in .*/; do
      # Remove the leading dot and trailing slash from the folder name
      folder_name=${folder#.}
      folder_name=${folder_name%/}

      # Skip the "." folder and any default folders listed in the default_folders array
      if [[ "$folder_name" != "." && ! " ${default_folders[@]} " =~ " $folder_name " ]]; then
        # Check if the folder is already subscribed
        if ! grep -Fxq "$folder_name" "$subscriptions_file"; then
          echo "Subscribing to folder: $folder_name"
          echo "$folder_name" >> "$subscriptions_file"
        fi
      fi
    done
  else
    echo "Maildir for $email not found at $maildir_path"
  fi
done

# Restart Dovecot to ensure changes are applied (optional)
sudo systemctl restart dovecot

echo "Subscription update completed."
