#!/bin/bash

# Function to display the help message
show_help() {
    echo "Usage: $(basename $0) [DIRECTORY] [NUMBER]"
    echo
    echo "This script renames files in the specified directory (or current directory if not specified)."
    echo "It changes the filenames based on a pattern where the last 15 characters"
    echo "are a 10-digit number followed by '.data' or '.meta'."
    echo "The script calculates a new 10-digit number which is NUMBER minus the old number."
    echo "It will exit without renaming any files if a new filename already exists"
    echo "or if the 10-digit number is larger than NUMBER."
    echo "The new files are output to the same directory as the input files."
    echo "You must confirm the action by typing 'YES' to proceed."
    echo
    echo "Arguments:"
    echo "  DIRECTORY    Optional. The directory containing files to rename (default is current directory)."
    echo "  NUMBER       Optional. The number to subtract from (default is 227639 [=nTimeSteps+1])."
    echo
    echo "Example:"
    echo "  $(basename $0) /path/to/directory"
    exit 1
}

# Default values
# DEFAULT_NUMBER is set to nTimeSteps+1
DEFAULT_NUMBER=227639
DEFAULT_DIRECTORY=$(pwd)

# Check for help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# Determine the directory and number
DIRECTORY=$DEFAULT_DIRECTORY
NUMBER=$DEFAULT_NUMBER

if [ "$#" -ge 1 ]; then
    if [[ -d $1 ]]; then
        DIRECTORY=$1
        shift
    elif [[ $1 =~ ^[0-9]+$ ]]; then
        NUMBER=$1
        shift
    else
        echo "Invalid argument: $1"
        show_help
    fi
fi

if [ "$#" -ge 1 ]; then
    if [[ $1 =~ ^[0-9]+$ ]]; then
        NUMBER=$1
    else
        echo "Invalid number: $1"
        show_help
    fi
fi

# Function to ask for user confirmation
confirm_action() {
    echo "You are about to rename files in the following directory: $DIRECTORY"
    echo "This will affect files where the last 15 characters are a 10-digit number followed by '.data' or '.meta'."
    echo "The renamed files will be placed in a subdirectory named 'offline_adj_file_renamed_dir'."
    echo "The renaming process will subtract each number from $NUMBER."
    read -p "Are you sure you want to proceed? Type 'YES' to confirm: " confirmation
    if [ "$confirmation" != "YES" ]; then
        echo "Operation cancelled by user."
        exit 1
    fi
}

# Ask for user confirmation
confirm_action

# Create a subdirectory for the renamed files if it doesn't exist
RENAME_DIR="$DIRECTORY/offline_adj_file_renamed_dir"
mkdir -p "$RENAME_DIR"

# Loop through files ending with ".data" or ".meta"
for file in "$DIRECTORY"/*.{data,meta}
do
    # Check if the file matches the pattern (last 15 characters)
    if [[ $file =~ ([0-9]{10})\.(data|meta)$ ]]
    then
        # Extract the 10-digit number and force it to be base 10
        old_number=$((10#${BASH_REMATCH[1]}))

        # Check if the old number is larger than NUMBER
        if (( old_number > NUMBER )); then
            echo "Error: The number $old_number in $file is larger than $NUMBER. Exiting."
            exit 1
        fi

        # Calculate the new number
        new_number=$((NUMBER - old_number))

        # Ensure that the new number is 10 digits, formatted with leading zeros
        formatted_new_number=$(printf "%010d" $new_number)

        # Extract the directory path from the original file path
        dir_path=$(dirname "$file")

        # Form the new filename in the subdirectory
        extension=${BASH_REMATCH[2]}
        base_name=$(basename "$file")
        new_file="${RENAME_DIR}/${base_name%_*}_${formatted_new_number}.${extension}"

        # Check if the new file already exists
        if [ -e "$new_file" ]; then
            echo "Error: $new_file already exists. Exiting."
            exit 1
        fi

        # Rename the file
        mv "$file" "$new_file"
    fi
done
