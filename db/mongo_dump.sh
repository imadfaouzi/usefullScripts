#!/bin/bash

# MongoDB connection parameters
MONGODB_HOST=""
MONGODB_PORT="27017"
MONGODB_USERNAME="admin"
MONGODB_PASSWORD=""

# Backup directory
BACKUP_DIR="/home/proddbserver/DUMPS/backups_$(date +%Y-%m-%d-%H-%M)"

mkdir -p "$BACKUP_DIR"

# Perform the backup
mongodump --quiet --host "$MONGODB_HOST" --port "$MONGODB_PORT" --username "$MONGODB_USERNAME" --password "$MONGODB_PASSWORD" --authenticationDatabase "admin" --out "$BACKUP_DIR"

# Check if mongodump was successful
if [ $? -ne 0 ]; then
    echo "Error: MongoDB backup failed." >&2
    exit 1
fi

# Uncomment the following line to remove backups older than 30 days
# find "$BACKUP_DIR" -type f -name "*.bson.gz" -mtime +30 -delete

echo "Backup process completed successfully."
