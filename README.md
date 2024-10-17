# email-label-auto-subscription-script
email-label-auto-subscription-script.sh is a Bash script that automates the management of IMAP email folder subscriptions for specified email accounts. It scans user-created folders within the Maildir directory structure, automatically subscribes them in the user's subscriptions file, and removes non-existent folders from the subscription list. It ensures that default folders like Archive, Sent, Drafts, Junk, Spam, and Trash are retained and never unsubscribed.

The script also preserves the versioning (V 2) in the subscriptions file and maintains the file's ownership and permissions after modification, making it safe to use in environments where strict security policies are in place.

**Features**
* Automatic Subscription: Automatically subscribes any newly created mail folders (labels) in the user's Maildir.
* Clean-up: Removes non-existent folders from the subscriptions file.
* Handles Default Folders: Preserves default folders like Sent, Trash, Drafts, and others, ensuring they remain subscribed.
* Maintains Ownership and Permissions: After modifying the subscriptions file, the script restores the original file ownership and permissions to avoid disrupting mail services.
* Handles Versioning: Supports and preserves versioning lines such as V 2 in the subscriptions file.
* Customizable for Specific Email Accounts: You can specify which email accounts should be managed by the script.

**Requirements**
* Bash: The script is written in Bash and should be run in a Linux environment.
* Root Access: Since the script modifies files under the Maildir structure, it requires sudo privileges to ensure the changes are applied correctly.

**Usage**
Prerequisites
* Ensure you have sudo access to the server where the Maildir directories are located.
* Make sure that the email accounts you wish to manage are correctly set up in the Maildir structure.

Setup
1. Clone this repository to your server:
    git clone https://github.com/digmlabs/email-label-auto-subscription-script.sh
2. Navigate into the directory:
    cd email-label-auto-subscription-script
3. Edit the emails array inside update_subscriptions.sh to include the email addresses you want the script to manage:
    emails=(
      "email1@domain.com"
      "email2@domain.com"
    )
4. Adjust the MAIL_DIR_BASE variable if your Maildir is located in a non-standard location:
    MAIL_DIR_BASE="/path/to/maildir"
    Example : MAIL_DIR_BASE="/home"

Running the Script
1. Make the script executable:
    chmod +x email-label-auto-subscription-script.sh
2. Run the script with sudo:
    sudo ./email-label-auto-subscription-script.sh
3. Optionally, restart Dovecot to apply any changes:
    sudo systemctl restart dovecot

**Contributors**
1. Karanbir Singh - DigmLabs.com

