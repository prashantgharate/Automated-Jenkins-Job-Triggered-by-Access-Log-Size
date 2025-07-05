#!/bin/bash
NOW=$(date +"%Y%m%d%H%M%S")
LOG_FILE="/var/log/nginx/access.log"
TMP_FILE="/tmp/access-$NOW.log"
cp "$LOG_FILE" "$TMP_FILE"
aws s3 cp "$TMP_FILE" s3://access-log-backup-prashant/
if [ $? -eq 0 ]; then
    echo "✅ Upload successful, clearing original log file..."
    sudo truncate -s 0 "$LOG_FILE"
else
    echo "❌ Upload failed!"
fi
