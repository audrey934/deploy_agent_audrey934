Student Attendance Tracker Project

The following script acts as a shell factory; it automates the creation of a workspace for Student Attendance Tracker, configures certain settings, and also handles the signal CTRL+c.

Here is an overview of the script's operations:

1. Checks if Python3 is installed and prints a warning if it is not
2. Prompts user to enter project name
3. Create the required directories and files:
   attendance_checker.py
   Helpers/assets.csv
   Helpers/config.json
   reports/reports.log
4. Checks if setup follows the correct directory structure
5. Asks the user to update attendance thresholds using the read command
6. Uses the sed command to replace default values with user input

N.B: The script handles (SIGINT/Ctrl+C) by deleting and archiving the created project folder

How to Run the Script
1. Open a terminal and run the command ./setup_project.sh

How to Implement the Archive Feature
While the script is running, press Ctrl+C




   
