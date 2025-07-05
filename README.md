#  Keylogger Detection Script

A simple bash-based detection tool to identify potential keyloggers or suspicious Python scripts on your system, especially ones running from hidden directories, cron jobs, or Python virtual environments.

---

##  What This Script Does

This script performs a series of checks across your system to detect signs of keylogger activity:

1. **Real-Time File Monitoring** (if `inotifywait` is installed)
2. **Suspicious Cron Jobs**
3. **Malicious systemd user services**
4. **Hidden Python/Shell scripts in `~/.config`**
5. **Long-running Python processes**
6. **Python scripts using virtual environments**
7. **Suspicious `.py` filenames (random or obfuscated names)**
8. **Suspicious directories containing keylogger patterns**
9. **Suspicious log/text files in `$HOME`**

---

##  Requirements

- Bash
- `ps`, `grep`, `awk`, `find` (default on most Linux/macOS)
- Optional: `inotify-tools` (for real-time file watching)

Install `inotify-tools` on Linux:

```bash
sudo apt update && sudo apt install inotify-tools
```
## How to Run
Save the script as `detect_keylogger.sh`

Make it executable:
```
chmod +x detect_keylogger.sh
```
## Run the script:
```
./detect_keylogger.sh
```

Each run will:

Create an alerts/ folder (if not already there)

Save results in a file like alert_YYYY-MM-DD_HH-MM-SS.log

## Project Structure
```
.
├── detect_keylogger.sh
├── alerts/
│   └── alert_<timestamp>.log
├── .gitignore
└── README.md
```

## Notes 
1. False positives are expected (e.g., Python packages or dev tools)

2. You can filter out known-safe directories with an exclusion list.
