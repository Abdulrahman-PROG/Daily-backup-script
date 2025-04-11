# Fedora Daily Backup Script

A Bash script for automated daily backups on Fedora with logging, log rotation, and local Postfix email alerts.

## Features
- Backs up `/home//data` (configurable) to `/home/backups` as `.tar.gz`.
- Keeps backups for 7 days.
- Logs to `/home/backup_logs`, retains 5 logs.
- Sends failure alerts via local Postfix to `admin@localhost`.
- Runs daily via cron at 3 AM.

## Requirements
- Fedora system.
- Postfix for local email delivery.
- Cron for scheduling.
- Write access to backup and log directories.

## Setup
1. **Clone the repo**:
   ```bash
   git clone https://github.com/Abdulrahman-PROG/Daily-backup-script.git
   cd fedora-daily-backup
