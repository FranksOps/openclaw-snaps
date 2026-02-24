# OpenClaw Snapshot Utility

A robust, automated backup script for capturing the critical state of an OpenClaw instance.

## Purpose

The `openclaw-snapshot.sh` script is designed to safely and reliably create compressed archives of a user's OpenClaw environment. It ensures that critical data, credentials, and workspace states are preserved exactly as they are, maintaining full file system fidelity.

This script is ideal for automated execution via `cron` or `systemd` timers to provide continuous data protection for an OpenClaw instance.

## What it Backs Up

The script captures the following specific components within the user's home directory:

*   `~/.openclaw/openclaw.json` (Main configuration/state file)
*   `~/.openclaw/credentials/` (Authentication and credential storage)
*   `~/.openclaw/workspace/` (Active workspace and data)

## Key Features

*   **Fidelity:** Preserves file permissions, ownership (numeric), Access Control Lists (ACLs), and Extended Attributes (`xattrs`).
*   **Safety:** Uses `set -Eeuo pipefail` to ensure the script fails securely on errors, unset variables, or pipeline failures.
*   **Validation:** Verifies that all required paths exist before attempting a backup.
*   **Integrity Checking:** Performs an immediate test extraction (`tar -tzf`) of the created archive to guarantee it is not corrupted.
*   **Logging:** Appends detailed output, including timestamps and success/failure states, to a log file (`~/.snapshots/openclaw_snapshot.log`).

## Installation

1.  Clone this repository or download the `openclaw-snapshot.sh` script.
2.  Make the script executable:

    ```bash
    chmod +x openclaw-snapshot.sh
    ```

3.  (Optional) Move it to a location in your PATH, such as `/usr/local/bin/` or `~/bin/`.

## Usage

You can run the script manually at any time:

```bash
./openclaw-snapshot.sh
```

By default, the script creates backups and logs in the `~/.snapshots` directory. The archive will be named using the format `openclaw_YYYYMMDD_HHMMSS.tar.gz`.

### Automating with Cron

To run the backup daily at 2:00 AM, add the following to your crontab (`crontab -e`):

```cron
0 2 * * * /path/to/openclaw-snapshot.sh
```

## Restore Procedure

To restore an OpenClaw instance from a generated snapshot, strictly follow these steps:

1.  **Stop OpenClaw:** Ensure any running OpenClaw processes are completely stopped to prevent data corruption during restoration.
2.  **Extract the Archive:** Extract the tarball directly into the user's home directory (`$HOME`). The script backs up using relative paths from the home directory.

    ```bash
    tar -xzpf openclaw_YYYYMMDD_HHMMSS.tar.gz -C "$HOME"
    ```
    *(Note: The `-p` flag is critical to ensure permissions are restored).*

3.  **Verify Permissions:** Confirm that the files have been restored with the correct permissions.

    ```bash
    ls -la ~/.openclaw
    ```

4.  **Restart OpenClaw:** It is now safe to start the OpenClaw service again.
