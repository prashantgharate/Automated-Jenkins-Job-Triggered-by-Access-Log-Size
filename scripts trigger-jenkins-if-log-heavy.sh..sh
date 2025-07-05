#!/bin/bash
ACTUAL_SIZE=$(stat -c%s /var/log/nginx/access.log)
MAX_SIZE=1073741824
if [ "$ACTUAL_SIZE" -ge "$MAX_SIZE" ]; then
    curl -X POST http://localhost:8080/job/upload-log-to-s3/build \
         --user "admin:<your-password>"
fi
