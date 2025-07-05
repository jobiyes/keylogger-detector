#!/bin/bash

# === [ CONFIG ] ===
ALERT_DIR="./alerts"
mkdir -p "$ALERT_DIR"

TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
ALERT_FILE="$ALERT_DIR/alert_$TIMESTAMP.log"

WATCH_DIRS=(
    "$HOME/.config"
    "$HOME/.local/bin"
    "$HOME/.cache"
    "/tmp"
)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$ALERT_FILE"
}

log "========== Keylogger Detection Started =========="

# === [ 1. Real-Time File Watcher using inotify ] ===
log "==== [1] Real-Time File Watcher ===="

if command -v inotifywait &> /dev/null; then
    for dir in "${WATCH_DIRS[@]}"; do
        eval dir="$dir"
        if [ -d "$dir" ]; then
            log "Watching: $dir"
            inotifywait -m -e create -e modify "$dir" |
            while read path action file; do
                log "ALERT: File $file was $action in $path"
            done &
        else
            log "Directory not found: $dir"
        fi
    done
else
    log "inotify-tools not installed. Skipping file watch."
fi

# === [ 2. Check cron jobs for suspicious Python/scripts ] ===
log "==== [2] Cron Job Check ===="
CRON_MATCHES=$(crontab -l 2>/dev/null | grep -Ei 'python|sh|\.py')
if [[ -n "$CRON_MATCHES" ]]; then
    log "ALERT: Suspicious cron jobs found:"
    echo "$CRON_MATCHES" >> "$ALERT_FILE"
else
    log "No suspicious cron jobs found."
fi

# === [ 3. Check systemd user services ] ===
log "==== [3] Systemd User Services Check ===="
SYSTEMD_SERVICES=$(find ~/.config/systemd/user -name '*.service' -exec grep -iE 'python|keylogger' {} + 2>/dev/null)
if [[ -n "$SYSTEMD_SERVICES" ]]; then
    log "ALERT: Suspicious systemd user services found:"
    echo "$SYSTEMD_SERVICES" >> "$ALERT_FILE"
else
    log "No suspicious systemd user services found."
fi

# === [ 4. Hidden scripts in ~/.config ] ===
log "==== [4] Hidden Script Check in ~/.config ===="
HIDDEN_SCRIPTS=$(find ~/.config -type f \( -name "*.py" -o -name "*.sh" \) -exec grep -iE 'pynput|keyboard|on_press' {} + 2>/dev/null)
if [[ -n "$HIDDEN_SCRIPTS" ]]; then
    log "ALERT: Suspicious hidden scripts found in ~/.config:"
    echo "$HIDDEN_SCRIPTS" >> "$ALERT_FILE"
else
    log "No suspicious scripts found in ~/.config."
fi

# === [ 5. Long-running Python processes ] ===
log "==== [5] Long-Running Python Processes ===="
LONG_PY_PROCESSES=$(ps -eo pid,etime,cmd | grep "[p]ython" | awk '$2 ~ /[0-9]+:[0-9]{2}:[0-9]{2}/')
if [[ -n "$LONG_PY_PROCESSES" ]]; then
    log "ALERT: Long-running Python processes detected:"
    echo "$LONG_PY_PROCESSES" >> "$ALERT_FILE"
else
    log "No long-running Python processes found."
fi

# === [ 6. Python virtual environment processes ] ===
log "==== [6] Python venv Detection ===="
VENV_PROCESSES=$(ps -eo pid,etime,cmd | grep "[p]ython" | grep -i "venv")
if [[ -n "$VENV_PROCESSES" ]]; then
    log "ALERT: Python processes using virtual environments:"
    echo "$VENV_PROCESSES" >> "$ALERT_FILE"
else
    log "No venv-based Python processes found."
fi

# === [ 7. Suspicious .py filenames in ~/.config ] ===
log "==== [7] Suspicious Filenames in ~/.config ===="
RANDOM_PY_FILES=$(find ~/.config -type f -regextype posix-extended -regex '.*/[a-zA-Z0-9_]{8,}\.py')
if [[ -n "$RANDOM_PY_FILES" ]]; then
    log "ALERT: Suspiciously named .py files:"
    echo "$RANDOM_PY_FILES" >> "$ALERT_FILE"
else
    log "No suspicious .py filenames found."
fi

# === [ 8. Suspicious Directories Based on Script Content ] ===
log "==== [8] Suspicious Directories in \$HOME ===="
SUS_DIRS=$(find "$HOME" -type f \( -name "*.py" -o -name "*.sh" \) -exec grep -iE 'pynput|keyboard|on_press' {} + 2>/dev/null | cut -d: -f1 | xargs -n1 dirname | sort -u)
if [[ -n "$SUS_DIRS" ]]; then
    log "ALERT: Suspicious scripts found in directories:"
    echo "$SUS_DIRS" >> "$ALERT_FILE"
else
    log "No suspicious directories found in user home."
fi

# === [ 9. Suspicious Keylogger Log Files (.txt/.log) ] ===
log "==== [9] Suspicious Log Files in \$HOME ===="
LOG_CONTENT_MATCHES=$(find "$HOME" -type f \( -name "*.log" -o -name "*.txt" \) -exec grep -iE 'keylog|keystroke|pynput' {} + 2>/dev/null)
if [[ -n "$LOG_CONTENT_MATCHES" ]]; then
    log "ALERT: Suspicious .log or .txt files found:"
    echo "$LOG_CONTENT_MATCHES" >> "$ALERT_FILE"
else
    log "No suspicious log files found."
fi

log "========== Keylogger Scan Complete =========="


