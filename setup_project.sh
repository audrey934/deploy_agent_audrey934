#!/bin/bash

#Python Health Check: Verification of Python3 installation
echo "Performing Python health check..."

if command -v python3; then
    echo " Python3 is installed."
    python3 --version
else
    echo "Python3 is NOT installed. Please install Python3 before running this script."
    exit 1
fi

#Asking user input for directory name and variable assignment

echo "Provide name of your directory:"
read name
BASE_DIR="attendance_tracker_$name"

#Setting the signla trap
trap ctrl_c INT

ctrl_c() {
    echo -e "\n[!] Script interrupted by user (SIGINT/Ctrl+C)."

    if [ -d "$BASE_DIR"  ]; then
        echo "Archiving current project directory..."
        tar -czf "${BASE_DIR}_archive.tar.gz" "$BASE_DIR"
        echo "Archive created: ${BASE_DIR}_archive.tar.gz"

        echo "Cleaning up incomplete directory..."
        rm -rf "$BASE_DIR"
        echo "Incomplete project directory deleted."
    fi

    exit 1
}

#Creating directories and files according to directory structure

mkdir "$BASE_DIR"
mkdir "$BASE_DIR/Helpers"
mkdir "$BASE_DIR/reports"

touch "$BASE_DIR/attendance_checker.py"
touch "$BASE_DIR/Helpers/assets.csv"
touch "$BASE_DIR/Helpers/config.json"
touch "$BASE_DIR/reports/reports.log"

#Checking Directory structure using array and for loop

dirs=("$BASE_DIR" "$BASE_DIR/Helpers" "$BASE_DIR/reports")
files=("$BASE_DIR/attendance_checker.py" "$BASE_DIR/Helpers/assets.csv" "$BASE_DIR/Helpers/config.json" "$BASE_DIR/reports/reports.log")

for d in "${dirs[@]}"; do
    if [ -d "$d" ]; then
        echo "Directory exists: $d"
    else
        echo "Directory missing: $d – creating now"
        mkdir -p "$d"
    fi
done

for f in "${files[@]}"; do
    if [ -f "$f" ]; then
        echo "File exists: $f"
    else
        echo "File missing: $f – creating now"
        touch "$f"
    fi
done


cat << EOF > "$BASE_DIR/attendance_checker.py" 
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)

    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']

        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100

            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

cat << EOF > "$BASE_DIR/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

cat << EOF > "$BASE_DIR/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}

EOF

cat << EOF > "$BASE_DIR/reports/reports.log"
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.


EOF

#Task 2: Dynamic Configuration
echo "Insert new warning value:" 
read a
echo "Insert new Failure value:"
read b

echo "Replacing values..."
sed -i "s/75/$a/" "$BASE_DIR/Helpers/config.json"
sed -i "s/50/$b/" "$BASE_DIR/Helpers/config.json"

echo "Values successfully replaced:"

echo "Project successful"


