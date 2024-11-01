#!/bin/bash
#
# Title: File timestamp update script
# Motivation: In large scale data processing, sometimes files get "stuck" and the file timestamp needed to be updated to get noticed an a new file and get processed.
#             While a system error or maintenance, many files could wait for processing, the files should be not updated.
#             If stuck files are updated endlessly, an system error could be unnoticed.
# Author: Adam Sebestyen https://github.com/Adams77777
# Copyright: MIT

# Remarks: 
#	Run the script with sufficent permissions to update the files
#	Each file is updated only once. Already updated file names are read from the logfile. Creating new logfiles could result repeated file update.
#   The script reads the modified timestamp (mtime) and modifies all 3 timestamps: access timestamp (atime), modified timestamp (mtime), change timestamp (ctime)
#	
# Example script start:
#	Update files in a folder with extension .dat and .txt, if the files are older then 30 minutes, and found not more then 15 files to update
#	./file_timestamp_update.sh /path/to/folder 30 ".dat,.txt" 15 /path/to/logfile.log
#	Update files in a folder, if the files are older then 15 minutes, and found not more then 50 files to update
#	./file_timestamp_update.sh /path/to/folder 15 "*" 50 /path/to/logfile.log
#	Update files in a folder, if the files are older then 15 minutes
#	./file_timestamp_update.sh /path/to/folder 15 "*" 0 /path/to/logfile.log

# Check for the correct number of parameters
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <target directory> <file age (minutes)> <file extensions (e.g., .txt,.log)> <max file count> <log file>"
    exit 1
fi

# Assign parameters
target_dir="$1"
file_age="$2"
file_extensions="$3"
max_files="$4"
log_file="$5"

#######################################
# Write script messages to standard output and in logfile with date
# Globals:
#   None
# Arguments:
#   $1 - message
#######################################
log_activity() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" | tee -a $log_file
}

# Check if the script has write access to the log file
if [ ! -w "$(dirname "$log_file")" ]; then
    echo "Error: The logfile cannot be written to. Permission denied!"
    exit 1
fi

# Logstart
log_activity "INFO: Script start."

# Check if the target directory exists
if [ ! -d "$target_dir" ]; then
    log_activity "ERROR: The target directory '$target_dir' does not exist."
	log_activity "INFO: Script run end."
    exit 1
fi

# Check if the script has read access to the target directory
if [ ! -r "$target_dir" ]; then
    log_activity "ERROR: The target directory '$target_dir' cannot be read. Permission denied."
	log_activity "INFO: Script run end."
    exit 1
fi

# Check if the file_age parameter is really a number
test_number='^[0-9]+$'
if ! [[ $file_age =~ $test_number ]] ; then
    log_activity "ERROR: The parameter file age is not a number: $file_age."
	log_activity "INFO: Script run end."
	exit 1
fi

# Check if the max_files parameter is really a number
if ! [[ $max_files =~ $test_number ]] ; then
    log_activity "ERROR: The parameter file age is not a number: $max_files."
	log_activity "INFO: Script run end."
	exit 1
fi

# Convert the comma-separated extensions into a format usable by find
IFS=',' read -r -a extensions_array <<< "$file_extensions"
find_conditions=""
for ext in "${extensions_array[@]}"; do
    if [ -n "$find_conditions" ]; then
        find_conditions+=" -o "
    fi
    find_conditions+="-name '*$ext'"
done

# Find files based on age (in minutes) and multiple extensions
find_command="find ""$target_dir"" -type f ""-mmin +""$file_age ""$find_conditions"
found_files=$(eval "$find_command")

# Count the found files
file_count=$(echo "$found_files" | awk NF | wc -l)
log_activity "INFO: Found $file_count files older than $file_age minutes with extensions $file_extensions in $target_dir."

if [ $file_count -gt 0 ]; then

    # Check if the number of found files exceeds the maximum allowed number, 0 = no check
    if [ "$file_count" -gt "$max_files" ] && [ ! "$max_files" -eq 0 ]; then
        log_activity "WARNING: Too many files found ($file_count). Maximum allowed is $max_files. No timestamps were updated."
        log_activity "INFO: Script run end."
        exit 1
    fi

    # Read the log file and store the of already updated files in a string
    updated_files=""
    if [ -f "$log_file" ]; then
        while IFS= read -r line; do
            # Extract filenames from the log entries
            if [[ "$line" == *"UPDATED:"* ]]; then
                updated_files+="${line#*\'}"
            fi
        done < "$log_file"
    fi

    # Update timestamps and log the updated files if not already updated
    echo "$found_files" | while read -r file; do
        # Check if the file has already been updated
        if [[ ! "$updated_files" == *"$file"* ]]; then
            touch -c "$file" &> /dev/null
			return_code=$?
			if [ "$return_code" -eq 0 ]; then
				log_activity "UPDATED: Timestamps updated for file '$file'."
			else
				log_activity "ERROR: failed to update file '$file'."
			fi
        else
            log_activity "SKIPPED: File '$file' was already updated."
        fi
    done
  
else
    log_activity "INFO: No files to update."
fi

# Logend
log_activity "INFO: Script run end."