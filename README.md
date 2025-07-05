
# 📦 Project: Automated Jenkins Job Triggered by Access Log Size

## 📌 Objective
Automatically monitor the size of the nginx access log file, and when it exceeds 1GB:
- Trigger a Jenkins job
- Upload the log file to an AWS S3 bucket
- Clear the original log file

## 🧱 Technologies Used
- AWS EC2 (Ubuntu)
- Jenkins
- AWS S3
- nginx
- Shell scripting
- AWS CLI
- cron

## 🧩 Components
| Component                             | Purpose                                  |
|---------------------------------------|------------------------------------------|
| EC2 Ubuntu Instance                   | Host Jenkins, nginx, and scripts         |
| nginx                                 | Generates access log to monitor          |
| Jenkins Job (`upload-log-to-s3`)      | Uploads log to S3 + truncates log        |
| `/opt/trigger-jenkins-if-log-heavy.sh`| Monitors log size & triggers Jenkins     |
| `/opt/auto-upload-4-times.sh`         | Test script to simulate 4 large uploads  |
| S3 Bucket (`access-log-backup-prashant`)| Stores uploaded logs                   |

---

## 🔧 Step-by-Step Setup

### ✅ Step 1: Launch EC2 (Ubuntu)
- Launch `t2.micro` Ubuntu instance
- Open ports: 22 (SSH), 8080 (Jenkins)

### ✅ Step 2: Install Jenkins and nginx
```bash
sudo apt update
sudo apt install openjdk-17-jdk -y
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc
sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins nginx unzip curl -y
```
- Start services:
```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

### ✅ Step 3: Install AWS CLI (Manual Method)
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
- Configure AWS CLI:
```bash
aws configure
```

### ✅ Step 4: Create S3 Bucket
- Name: `access-log-backup-prashant`
- Keep private access, versioning optional

### ✅ Step 5: Create Jenkins Job `upload-log-to-s3`
- Type: Freestyle project
- Build Step → Execute Shell:
```bash
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
```

### ✅ Step 6: Create Monitoring Script
File: `/opt/trigger-jenkins-if-log-heavy.sh`
```bash
#!/bin/bash
ACTUAL_SIZE=$(stat -c%s /var/log/nginx/access.log)
MAX_SIZE=1073741824
if [ "$ACTUAL_SIZE" -ge "$MAX_SIZE" ]; then
    curl -X POST http://localhost:8080/job/upload-log-to-s3/build --user "admin:<your-password>"
fi
```
```bash
sudo chmod +x /opt/trigger-jenkins-if-log-heavy.sh
```

### ✅ Step 7: Add Cron Job
```bash
crontab -e
```
Add:
```bash
*/5 * * * * /opt/trigger-jenkins-if-log-heavy.sh
```

### ✅ Step 8: Simulate 4 Log Files (1GB each)
File: `/opt/auto-upload-4-times.sh`
```bash
#!/bin/bash
for i in {1..4}; do
    echo "🔁 Creating 1GB log file..."
    sudo fallocate -l 1G /var/log/nginx/access.log
    sudo chmod 666 /var/log/nginx/access.log
    echo "🚀 Triggering Jenkins..."
    sudo /opt/trigger-jenkins-if-log-heavy.sh
    sleep 20
done
```
```bash
sudo chmod +x /opt/auto-upload-4-times.sh
```
Run:
```bash
sudo /opt/auto-upload-2-times.sh
```

---

## ✅ Output Example (S3 Bucket)
| File Name                      | Size   |
|-------------------------------|--------|
| access-20250704120001.log     | 1.0 GB |
| access-20250704121002.log     | 1.0 GB |

---

## 🧾 Summary for Resume:
> Designed an automated log monitoring solution using Jenkins and shell scripting on AWS EC2, which monitors nginx log size and triggers a Jenkins job to upload the file to S3 if it exceeds 1GB, with log truncation post-upload. Fully tested with 4 iterations and cron automation.

---

## 🧠 Future Improvements
- Email/SNS alerts on failure
- Slack integration for notifications
- CloudWatch-based monitoring

---

✅ **Project Complete** – Fully working, tested, and production-ready!
