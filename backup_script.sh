#!/bin/bash

# backup_script.sh

# Configurable variables
SOURCE_DIR="/var/www"                  # Directory to backup
BACKUP_DIR="/backups"                  # Backup storage location
RETENTION_DAYS=7                       # Number of days to keep backups
LOG_DIR="/var/log/backups"             # Log storage location
LOG_RETENTION=5                        # Number of logs to keep
EMAIL=""              # Admin email for alerts

# Fixed variables
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="backup_$DATE.tar.gz"
LOG_FILE="$LOG_DIR/backup_$DATE.log"
HOSTNAME=$(hostname)

# Function to send email alert
send_alert() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "[Backup Failure] $subject on $HOSTNAME" "$EMAIL"
}

# Create necessary directories
mkdir -p "$BACKUP_DIR" "$LOG_DIR"

# Start logging
echo "Backup started at $(date)" > "$LOG_FILE"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist" >> "$LOG_FILE"
    send_alert "Source Directory Missing" "Backup failed: Source directory $SOURCE_DIR not found"
    exit 1
fi

# Perform backup
tar -czf "$BACKUP_DIR/$BACKUP_FILE" "$SOURCE_DIR" 2>> "$LOG_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Backup compression failed" >> "$LOG_FILE"
    send_alert "Backup Compression Failed" "Failed to create backup archive"
    exit 1
fi

# Verify backup file was created
if [ ! -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    echo "Error: Backup file not created" >> "$LOG_FILE"
    send_alert "Backup File Missing" "Backup file was not created successfully"
    exit 1
fi

echo "Backup completed successfully at $(date)" >> "$LOG_FILE"

# Cleanup old backups
find "$BACKUP_DIR" -type f -name "backup_*.tar.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;
if [ $? -ne 0 ]; then
    echo "Warning: Old backup cleanup failed" >> "$LOG_FILE"
    send_alert "Cleanup Failed" "Failed to remove old backups"
fi

# Rotate logs
find "$LOG_DIR" -type f -name "backup_*.log" | sort -r | tail -n +$((LOG_RETENTION + 1)) | xargs -I {} rm -f {}
if [ $? -ne 0 ]; then
    echo "Warning: Log rotation failed" >> "$LOG_FILE"
    send_alert "Log Rotation Failed" "Failed to rotate logs"
fi

echo "Backup process finished at $(date)" >> "$LOG_FILE"
exit 0
