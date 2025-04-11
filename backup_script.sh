#!/bin/bash

SOURCE_DIR="/home/user/data"        # Directory to back up (change as needed)
BACKUP_DEST="/backups"              # Backup storage
BACKUP_RETENTION=7                  # Days to keep backups
LOG_DEST="/var/log/mybackups"       # Log storage
LOG_RETENTION=5                     # Number of logs to keep
BACKUP_FILE="backup-$(date +%Y%m%d_%H%M%S).tar.gz"  # Backup file name
LOG_FILE="$LOG_DEST/backup-$(date +%Y%m%d_%H%M%S).log"  # Log file name
EMAIL_TO="admin@localhost"          # Email for alerts
EMAIL_FROM="backup@localhost"       # Sender email

# Create directories if they don't exist
mkdir -p "$BACKUP_DEST" "$LOG_DEST"

# Logg
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# alert 
alert() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "$subject" -r "$EMAIL_FROM" "$EMAIL_TO"
}

# Start backup 
log "Starting backup of $SOURCE_DIR"

# Create backup
if tar -czf "$BACKUP_DEST/$BACKUP_FILE" "$SOURCE_DIR" 2>/dev/null; then
    log "Created backup: $BACKUP_FILE"
else
    log "Error: Failed to create backup"
    alert "Backup Failed - $(date +%Y-%m-%d)" "Could not back up $SOURCE_DIR. Check $LOG_FILE."
    exit 1
fi

# Verify backup 
if [ ! -f "$BACKUP_DEST/$BACKUP_FILE" ]; then
    log "Error: Backup file $BACKUP_FILE not found"
    alert "Backup Failed - $(date +%Y-%m-%d)" "Backup file $BACKUP_FILE missing. Check $LOG_FILE."
    exit 1
fi

# Clean old backups
find "$BACKUP_DEST" -type f -name "backup-*.tar.gz" -mtime +"$BACKUP_RETENTION" -delete
log "Removed backups older than $BACKUP_RETENTION days"

# Rotate logs
find "$LOG_DEST" -type f -name "backup-*.log" -exec ls -t {} + | tail -n +"$((LOG_RETENTION + 1))" | xargs -r rm -f
log "Rotated logs, keeping last $LOG_RETENTION logs"

log "Backup completed successfully"
exit 0
