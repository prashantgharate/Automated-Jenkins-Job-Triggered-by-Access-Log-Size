#!/bin/bash
for i in {1..2}; do
    echo "🔁 Creating 1GB log file..."
    sudo fallocate -l 1G /var/log/nginx/access.log
    sudo chmod 666 /var/log/nginx/access.log
    echo "🚀 Triggering Jenkins..."
    sudo /opt/trigger-jenkins-if-log-heavy.sh
    sleep 20
done
