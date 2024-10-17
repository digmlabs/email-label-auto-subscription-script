# email-label-auto-subscription-script
email-label-auto-subscription-script.sh is a Bash script that automates the management of IMAP email folder subscriptions for specified email accounts. It scans user-created folders within the Maildir directory structure, automatically subscribes them in the user's subscriptions file, and removes non-existent folders from the subscription list. It ensures that default folders like Archive, Sent, Drafts, Junk, Spam, and Trash are retained and never unsubscribed.

The script also preserves the versioning (V 2) in the subscriptions file and maintains the file's ownership and permissions after modification, making it safe to use in environments where strict security policies are in place.

Features
* Automatic Subscription: Automatically subscribes any newly created mail folders (labels) in the user's Maildir.
* Clean-up: Removes non-existent folders from the subscriptions file.
* Handles Default Folders: Preserves default folders like Sent, Trash, Drafts, and others, ensuring they remain subscribed.
* Maintains Ownership and Permissions: After modifying the subscriptions file, the script restores the original file ownership and permissions to avoid disrupting mail services.
* Handles Versioning: Supports and preserves versioning lines such as V 2 in the subscriptions file.
* Customizable for Specific Email Accounts: You can specify which email accounts should be managed by the script.
