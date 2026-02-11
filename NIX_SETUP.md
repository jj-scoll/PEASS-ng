# NixOS Build Setup for PEASS-ng

This repository now includes Nix flake support for building PEASS-ng tools on NixOS.

## Quick Start

### Build linPEAS

```bash
# Build the linpeas standalone executable (downloads latest official release)
nix build .#linpeas

# Run it
./result/bin/linpeas -h

# Or run directly without building
nix run .#linpeas -- -h

# The executable is fully standalone - you can copy it anywhere
cp ./result/bin/linpeas ~/bin/
```

### Development Environment

```bash
# Enter development shell with all dependencies
nix develop

# Or use direnv (if you have it installed)
direnv allow
```

### Using the Development Shell

Once in the dev shell, you can build manually:

```bash
# Build linPEAS manually
cd linPEAS
python3 -m builder.linpeas_builder --small --output /tmp/linpeas.sh

# Or build with all checks (requires network access outside Nix sandbox)
python3 -m builder.linpeas_builder --all-no-fat --output /tmp/linpeas_full.sh
```

## Available Packages

- `linpeas` - Linux Privilege Escalation Awesome Script (full version, ~972KB standalone executable)
- `winpeas` - Windows Privilege Escalation Awesome Script (C# .exe, requires Mono) [WIP]

## Notes

### LinPEAS Version

The Nix build downloads the **official latest release** of linPEAS from the PEASS-ng GitHub releases. This is the full-featured version with all checks and embedded tools, providing:

- ✅ All privilege escalation checks
- ✅ Embedded linux-exploit-suggester
- ✅ Full regex patterns for credential detection
- ✅ Complete enumeration capabilities
- ✅ Standalone executable (no dependencies needed on target system)

The executable is **972KB** with over **8,500 lines** of checks.

### Why Download Instead of Build?

Building linPEAS from source in Nix requires:
1. Network access during build (Nix builds are sandboxed)
2. Downloading third-party tools at build time (breaks reproducibility)

By downloading the official pre-built release:
- ✅ Fully reproducible builds (hash-verified)
- ✅ Always get the latest stable version
- ✅ Faster builds (no Python builder execution)
- ✅ Official, tested releases

## Security Research Environments

This flake includes specialized development environments for security research and testing.

### Red Team / Security Research Shell

For offensive security research, penetration testing, and understanding attack vectors:

```bash
nix develop .#security
```

**Included tools:**
- **System auditing**: lynis, chkrootkit
- **Network tools**: nmap, wireshark, tcpdump, netcat
- **D-Bus security**: dbus-send, dbus-monitor, gdbus
- **Binary analysis**: radare2, binwalk, strace, ltrace, hexyl
- **Password tools**: john, hashcat
- **Container security**: podman

**Example workflows:**

```bash
# Enter the security shell
nix develop .#security

# D-Bus service enumeration
gdbus call --session --dest org.freedesktop.DBus \
  --object-path /org/freedesktop/DBus \
  --method org.freedesktop.DBus.ListNames

# Introspect a service
gdbus introspect --session \
  --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications

# Monitor D-Bus traffic
dbus-monitor --session

# System security audit
sudo lynis audit system

# Network enumeration
nmap -sV localhost

# Binary analysis
r2 /bin/ls
strace ls
```

### Blue Team / Defensive Security Shell

For defensive security, incident response, and threat hunting:

```bash
nix develop .#blueteam
```

**Included tools:**
- **Monitoring**: osquery, htop, iftop, nethogs, sysstat
- **Log analysis**: lnav, multitail, goaccess
- **Intrusion detection**: aide, fail2ban
- **Forensics**: sleuthkit, volatility3, foremost
- **Network monitoring**: tcpdump, wireshark, tshark

**Example workflows:**

```bash
# Enter the blue team shell
nix develop .#blueteam

# Real-time system monitoring
htop

# Network bandwidth monitoring
sudo iftop

# Advanced log analysis
lnav /var/log/auth.log /var/log/syslog

# Threat hunting with osquery
osqueryi
SELECT * FROM listening_ports WHERE port != 0;
SELECT * FROM processes WHERE name LIKE '%suspicious%';
SELECT * FROM users WHERE type = 'local';

# File integrity monitoring
sudo aide --init
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
sudo aide --check

# Capture network traffic for analysis
sudo tcpdump -i any -w /tmp/capture.pcap
wireshark /tmp/capture.pcap

# Forensic analysis
fls disk.img
icat disk.img 123 > recovered_file

# Memory forensics (if you have a memory dump)
vol -f memory.dump linux.pslist
vol -f memory.dump linux.bash
```

### Security Learning Path

**1. D-Bus Security (Red Team)**

D-Bus is a common local privilege escalation and phishing vector:

```bash
nix develop .#security

# List all session services
gdbus call --session --dest org.freedesktop.DBus \
  --object-path /org/freedesktop/DBus \
  --method org.freedesktop.DBus.ListNames

# Test notification spoofing
gdbus call --session \
  --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications \
  --method org.freedesktop.Notifications.Notify \
  "System Update" 0 "dialog-password" \
  "Test Notification" "This is a test" "[]" "{}" 5000

# Monitor D-Bus for sensitive data
dbus-monitor --session | grep -i "password\|token\|secret"
```

**2. System Hardening (Blue Team)**

Use defensive tools to secure your system:

```bash
nix develop .#blueteam

# Full security audit
sudo lynis audit system

# Check for rootkits
sudo chkrootkit

# Monitor for suspicious activity
osqueryi
SELECT * FROM processes WHERE on_disk = 0;  -- Fileless malware
SELECT * FROM shell_history;                -- User commands
SELECT * FROM startup_items;                -- Persistence

# Set up file integrity monitoring
sudo aide --init
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Daily check (add to cron)
sudo aide --check
```

**3. Incident Response Workflow**

When you detect suspicious activity:

```bash
nix develop .#blueteam

# 1. Capture network traffic
sudo tcpdump -i any -w /tmp/incident_$(date +%Y%m%d_%H%M%S).pcap

# 2. Query running processes
osqueryi "SELECT * FROM processes WHERE parent = 1;"

# 3. Check network connections
osqueryi "SELECT * FROM process_open_sockets;"

# 4. Review logs
lnav /var/log/auth.log /var/log/syslog

# 5. Forensic disk analysis (if needed)
sudo fls -r /dev/sda1 > /tmp/file_listing.txt

# 6. Memory analysis (if you captured a dump)
vol -f memory.dump linux.pslist > /tmp/processes.txt
```

## Compatibility

This Nix setup works on:
- NixOS
- Linux with Nix package manager
- macOS with Nix package manager (for linPEAS; winPEAS requires Linux/Mono)

## Traditional Build Methods

The original build methods still work:
- Python builder for linPEAS (see `linPEAS/builder/README.md`)
- Visual Studio / msbuild for winPEAS (see `winPEAS/winPEASexe/README.md`)
