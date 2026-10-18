# Week 1 — Linux & Terminal Mastery

# Day 1 — Core File System Commands

 The Linux File System Tree
/               ← root of everything
├── /home       ← user home directories
├── /etc        ← system configuration files
├── /var        ← logs, databases, mail (/var/log)
├── /bin        ← essential commands (ls, cp, mv)
├── /usr        ← user programs and libraries
├── /tmp        ← temporary files (cleared on reboot)
├── /proc       ← virtual: running process info
└── /dev        ← device files (disks, terminals)

# Core Commands 
Navigation
pwd                        # print working directory
ls                         # list files
ls -la                     # list all files (including hidden) with details
ls -lh                     # human-readable file sizes
cd /var/log                # change to directory
cd ~                       # go to home directory
cd ..                      # go up one level
cd -                       # go back to previous directory

# Files and Directories
mkdir projects             # create directory
mkdir -p a/b/c             # create nested directories
touch notes.txt            # create empty file
cp file.txt backup.txt     # copy file
cp -r folder/ backup/      # copy directory recursively
mv old.txt new.txt         # rename or move file
rm file.txt                # delete file
rm -rf folder/             # delete directory and all contents (careful!)

# Viewing Files
cat /etc/os-release        # print file to screen
less /var/log/syslog       # scroll through large files (q to quit)
head -20 file.txt          # first 20 lines
tail -20 file.txt          # last 20 lines
tail -f /var/log/syslog    # live log watching (Ctrl+C to stop)

# Finding Things
find /etc -name "*.conf"   # find all .conf files under /etc
find / -size +100M         # find files larger than 100 MB
which python3              # find location of a command
whereis nginx              # find binary + man page location

# Day 2 — File Permissions, Users & Groups
# Understanding Permissions
Every file has 3 permission sets: owner, group, others
ls -la
# Output:
# -rwxr-xr-- 1 ubuntu devs 1234 Oct 1 10:00 script.sh
#  ↑↑↑↑↑↑↑↑↑
#  │└──┤└──┤└──┤
#  │   │   │   └─ others: r-- (read only)
#  │   │   └───── group:  r-x (read + execute)
#  │   └───────── owner:  rwx (read + write + execute)
#  └───────────── file type: - (file), d (dir), l (link)

# Permission Values
Symbol	Number	Meaning
r	     4	    Read
w	     2	    Write
x	     1	   Execute
-	     0	  No permission

# Common combinations:
•	755 → rwxr-xr-x (owner: all, group+others: read+execute)
•	644 → rw-r--r-- (owner: read+write, others: read only)
•	600 → rw------- (owner only — used for SSH keys!)
•	777 → rwxrwxrwx (everyone full access — dangerous, avoid)
chmod — Change Permissions

# Numeric mode
chmod 755 script.sh        # rwxr-xr-x
chmod 600 ~/.ssh/id_rsa    # rw------- (required for SSH keys)
chmod 644 config.txt       # rw-r--r--

# Symbolic mode
chmod +x script.sh         # add execute for everyone
chmod u+w file.txt         # add write for owner (u)
chmod go-r file.txt        # remove read from group (g) and others (o)
chmod -R 755 folder/       # recursive (apply to all files inside)
chown — Change Ownership
chown ubuntu file.txt              # change owner to ubuntu
chown ubuntu:devs file.txt         # change owner and group
chown -R ubuntu:ubuntu projects/   # recursive ownership change
sudo — Run as Root
sudo apt install nginx     # install package as root
sudo -i                    # become root (use with caution)
sudo -l                    # list your sudo permissions
cat /etc/sudoers           # sudo configuration (use visudo to edit)

# User and Group Management
# Users
whoami                     # current username
id                         # user ID, group IDs
useradd -m -s /bin/bash alice    # create user with home dir
passwd alice               # set password
usermod -aG sudo alice     # add alice to sudo group
userdel -r alice           # delete user and home directory

# Groups
groupadd developers        # create group
usermod -aG developers bob # add bob to developers group
groups bob                 # list bob's groups

# Important files
cat /etc/passwd            # all users (username:x:UID:GID:comment:home:shell)
cat /etc/shadow            # hashed passwords (root only)
cat /etc/group             # all groups

# Day 3 — Bash Scripting
# Script Structure
  #!/bin/bash
     The shebang line tells the OS to use bash.Always the first line of every script

# Make it executable before running:
# chmod +x script.sh
# ./script.sh

Variables
#!/bin/bash

NAME="cloud-engineer"           # no spaces around =
ENV="production"
PORT=8080

echo "Hello, $NAME"             # use $ to reference
echo "Environment: ${ENV}"      # braces for clarity
echo "Running on port: $PORT"

# Command substitution — store output in variable
CURRENT_DATE=$(date +%Y-%m-%d)
FILE_COUNT=$(ls /var/log | wc -l)
echo "Today: $CURRENT_DATE, Log files: $FILE_COUNT"

# Read user input
read -p "Enter your name: " USERNAME
echo "Welcome, $USERNAME"

# Conditionals
#!/bin/bash

DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

if [ $DISK_USAGE -gt 90 ]; then
    echo "CRITICAL: Disk is ${DISK_USAGE}% full!"
elif [ $DISK_USAGE -gt 75 ]; then
    echo "WARNING: Disk is ${DISK_USAGE}% full"
else
    echo "OK: Disk usage is ${DISK_USAGE}%"
fi

# File/directory checks
if [ -f "/etc/nginx/nginx.conf" ]; then
    echo "Nginx config exists"
fi

if [ -d "/var/log/nginx" ]; then
    echo "Nginx log directory exists"
fi

# String comparison
ENV="production"
if [ "$ENV" == "production" ]; then
    echo "Running in production — be careful!"
fi

# Loops
#!/bin/bash

# For loop — list of items
for SERVER in web-01 web-02 web-03; do
    echo "Checking server: $SERVER"
    ping -c 1 $SERVER > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "  $SERVER is UP"
    else
        echo "  $SERVER is DOWN"
    fi
done

# For loop — range of numbers
for i in {1..5}; do
    echo "Iteration $i"
done

# While loop
COUNTER=0
while [ $COUNTER -lt 5 ]; do
    echo "Counter: $COUNTER"
    ((COUNTER++))
done

# Loop over files
for FILE in /var/log/*.log; do
    SIZE=$(du -sh $FILE | cut -f1)
    echo "$FILE → $SIZE"
done

# Functions
#!/bin/bash

# Define a function
check_service() {
    SERVICE=$1          # $1 is first argument passed to function
    if systemctl is-active --quiet $SERVICE; then
        echo "✓ $SERVICE is running"
    else
        echo "✗ $SERVICE is NOT running"
        systemctl start $SERVICE
        echo "  → Started $SERVICE"
    fi
}

# Call the function
check_service nginx
check_service ssh
check_service cron

# Day 4 — Process Management & Cron Jobs
# Viewing Processes
ps aux                     # all running processes
ps aux | grep nginx        # find specific process
top                        # live process viewer (q to quit)
htop                       # better version of top (sudo apt install htop)
pgrep nginx                # get PID of process by name

# Understanding top Output
PID    USER    %CPU  %MEM   COMMAND
1234   ubuntu   0.5   1.2   nginx
5678   root    25.0   8.5   python3 app.py
•	PID — Process ID (unique number for each process)
•	%CPU — CPU usage percentage
•	%MEM — Memory usage percentage

# Killing Processes
kill 1234                  # send SIGTERM (graceful stop)
kill -9 1234               # send SIGKILL (force stop, last resort)
killall nginx              # kill all processes named nginx

# systemctl — Manage System Services
sudo systemctl start nginx       # start service
sudo systemctl stop nginx        # stop service
sudo systemctl restart nginx     # restart service
sudo systemctl reload nginx      # reload config without restart
sudo systemctl status nginx      # check status
sudo systemctl enable nginx      # start on boot
sudo systemctl disable nginx     # do not start on boot
sudo systemctl list-units        # list all services

# Check service logs
journalctl -u nginx              # all nginx logs
journalctl -u nginx -f           # follow live nginx logs

# Cron Jobs — Scheduled Tasks
Cron runs commands on a schedule. 
crontab -e                 # edit your cron jobs
crontab -l                 # list your cron jobs
crontab -r                 # delete all cron jobs (careful!)
Cron syntax:
┌──────────── minute (0-59)
│  ┌─────────── hour (0-23)
│  │  ┌────────── day of month (1-31)
│  │  │  ┌───────── month (1-12)
│  │  │  │  ┌────────── day of week (0=Sunday, 6=Saturday)
│  │  │  │  │
*  *  *  *  *  command
Examples:
# Run backup script every day at 2am
0 2 * * * /home/ubuntu/backup.sh >> /var/log/backup.log 2>&1

# Check disk every 15 minutes
*/15 * * * * /home/ubuntu/disk_alert.sh

# Clean temp files every Sunday at midnight
0 0 * * 0 rm -rf /tmp/old_*

# Run on 1st of every month at 6am
0 6 1 * * /home/ubuntu/monthly_report.sh

# Day 5 — SSH & Remote Access

How SSH Works
Your Machine                    Remote Server
     │                               │
     │── SYN ──────────────────────>│ port 22
     │<─ SYN-ACK ───────────────────│
     │── ACK ──────────────────────>│
     │                               │
     │── key exchange (ECDH) ──────>│ negotiate encryption
     │── public key sent ──────────>│ server verifies
     │<─ authenticated ─────────────│
     │                               │
     │═══ encrypted tunnel ═════════│ all traffic encrypted

# Generate a new key pair (press Enter to accept defaults)
ssh-keygen -t ed25519 -C "your.email@gmail.com"

# This creates:
  ~/.ssh/id_ed25519      ← PRIVATE key — never share this
  ~/.ssh/id_ed25519.pub  ← PUBLIC key — place this on servers

# View your public key
cat ~/.ssh/id_ed25519.pub

# Set correct permissions (SSH refuses to work without this)
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Copy Public Key to Server
# Automated way
ssh-copy-id -i ~/.ssh/id_ed25519.pub ubuntu@SERVER_IP

# Manual way (useful for cloud instances)
# On the remote server, add your public key to:
echo "YOUR_PUBLIC_KEY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

Connecting via SSH
# Basic connection
ssh ubuntu@192.168.1.100

# With specific key file (AWS EC2 uses .pem files)
ssh -i ~/.ssh/my-ec2-key.pem ec2-user@54.123.45.67

# With port (if SSH is not on port 22)
ssh -p 2222 ubuntu@192.168.1.100

# Run a single command without interactive session
ssh ubuntu@192.168.1.100 'df -h'

# Copy files with SCP
scp file.txt ubuntu@192.168.1.100:~/
scp -r folder/ ubuntu@192.168.1.100:~/
scp ubuntu@192.168.1.100:~/remote.txt ./local.txt
SSH Config File — Your Time Saver
Instead of typing ssh -i ~/.ssh/my-key.pem ec2-user@54.123.45.67, set up ~/.ssh/config:
# ~/.ssh/config

# AWS EC2 web server
Host web-prod
    HostName 54.123.45.67
    User ec2-user
    IdentityFile ~/.ssh/aws-prod.pem
    Port 22

# AWS EC2 dev server
Host web-dev
    HostName 10.0.0.50
    User ubuntu
    IdentityFile ~/.ssh/aws-dev.pem

# Jump through bastion host
Host private-server
    HostName 10.0.1.20
    User ubuntu
    IdentityFile ~/.ssh/aws-dev.pem
    ProxyJump web-dev
Now just type:
ssh web-prod          # connects with all settings automatically
ssh private-server    # jumps through bastion automatically
Hardening SSH (You Will Do This on Every Cloud Server)
# Edit SSH server config
sudo nano /etc/ssh/sshd_config

# Change these settings:
Port 2222                        # change from 22 (optional)
PermitRootLogin no               # never allow root login
PasswordAuthentication no        # keys only, no passwords
PubkeyAuthentication yes         # enable key auth
MaxAuthTries 3                   # limit brute force attempts
AllowUsers ubuntu ec2-user       # whitelist specific users

# Restart SSH after changes
sudo systemctl restart sshd

# Day 6 — Text Processing Tools

# grep — Search Text
# Basic search
grep "error" /var/log/syslog        # find lines containing 'error'
grep -i "error" file.txt            # case-insensitive
grep -n "error" file.txt            # show line numbers
grep -r "TODO" ~/projects/          # recursive search in directory
grep -v "DEBUG" app.log             # lines NOT containing DEBUG
grep -c "ERROR" app.log             # count matching lines
grep -A 3 "ERROR" app.log           # show 3 lines AFTER match
grep -B 3 "ERROR" app.log           # show 3 lines BEFORE match

# Regex patterns
grep "^ERROR" app.log               # lines starting with ERROR
grep "ERROR$" app.log               # lines ending with ERROR
grep -E "ERROR|WARN" app.log        # ERROR or WARN (extended regex)
grep -E "[0-9]{3}" file.txt         # lines with 3-digit numbers

# Practical cloud examples
grep "Failed password" /var/log/auth.log     # failed SSH attempts
grep "GET /api" nginx/access.log             # API requests
grep -i "exception" application.log          # application errors

# awk — Column Processing
# awk sees each line as fields separated by whitespace

   $1 = first field, $2 = second, $NF = last field

# Print specific columns
ps aux | awk '{print $1, $2, $11}'     # user, PID, command
df -h | awk '{print $1, $5}'           # filesystem and usage%

# Filter rows + print columns
awk '$3 > 1000' /etc/passwd             # UIDs above 1000
awk -F: '$3 >= 1000 {print $1}' /etc/passwd   # users with UID>=1000 (-F: sets delimiter)

# Math operations
awk '{sum += $4} END {print "Total:", sum}' sales.csv

# Practical examples
# Get IPs from nginx access log
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head 10

# Extract CPU usage from ps
ps aux | awk '{print $3, $11}' | sort -rn | head 5
sed — Stream Editor (Find & Replace)
# Basic substitution: s/old/new/
sed 's/foo/bar/' file.txt              # replace first 'foo' per line
sed 's/foo/bar/g' file.txt            # replace ALL 'foo' per line
sed -i 's/foo/bar/g' file.txt         # edit file in-place

# Delete lines
sed '/^#/d' config.txt                # delete comment lines
sed '/^$/d' file.txt                  # delete empty lines
sed '5d' file.txt                     # delete line 5

# Print specific lines
sed -n '10,20p' file.txt              # print lines 10-20

# Practical examples
# Update a config value
sed -i 's/port=8080/port=80/' app.conf

# Remove trailing whitespace
sed -i 's/[[:space:]]*$//' file.txt

# Comment out a line
sed -i 's/^START_SERVICE=yes/#START_SERVICE=yes/' config

# cut, sort, uniq, wc
# cut — extract columns by delimiter
cut -d: -f1 /etc/passwd               # first field (username), colon delimiter
cut -d, -f2,4 data.csv                # columns 2 and 4 from CSV
cut -c1-10 file.txt                   # first 10 characters of each line

# sort — sort lines
sort file.txt                         # alphabetical sort
sort -n numbers.txt                   # numerical sort
sort -rn numbers.txt                  # reverse numerical
sort -t: -k3 -n /etc/passwd           # sort by 3rd field (UID)

# uniq — remove duplicate lines (must be sorted first)
sort file.txt | uniq                  # unique lines
sort file.txt | uniq -c               # count occurrences
sort file.txt | uniq -d               # only show duplicates

# wc — word/line/byte count
wc -l file.txt                        # count lines
wc -w file.txt                        # count words
cat /etc/passwd | wc -l               # count total users

# Pipes — Combining Commands
Pipes (|) pass the output of one command as input to the next. This is where the power is.
# Top 10 IP addresses hitting your web server
cat /var/log/nginx/access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head 10

# Find all failed SSH attempts and count by IP
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn

# Disk usage of all directories in /var, sorted by size
du -sh /var/* 2>/dev/null | sort -rh | head 10

# All processes using more than 1% CPU
ps aux | awk '$3 > 1.0' | sort -k3 -rn

# Count errors per hour in application log
grep "ERROR" app.log | awk '{print $2}' | cut -d: -f1 | sort | uniq -c
