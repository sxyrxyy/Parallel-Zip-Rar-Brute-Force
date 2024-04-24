#!/bin/bash
# Check required commands
command -v unrar >/dev/null 2>&1 || { echo "unrar command not found. Please install unrar." >&2; exit 1; }
command -v 7z >/dev/null 2>&1 || { echo "7z command not found. Please install p7zip-full." >&2; exit 1; }
command -v parallel >/dev/null 2>&1 || { echo "GNU Parallel not found. Please install parallel." >&2; exit 1; }

# Usage function to display help
usage() {
    echo "Usage: $0 [-d <directory>] [-w <wordlist>] [-e <extract_dir>] [-f <file>]"
    echo "  -d <directory>   : The directory containing RAR or ZIP files."
    echo "  -w <wordlist>    : The dictionary file containing potential passwords."
    echo "  -e <extract_dir> : Directory where files will be extracted if password is correct."
    echo "  -f <file>        : Single RAR or ZIP file to crack."
    exit 1
}
directory=""
wordlist=""
extract_dir=""
single_file=""

if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi


# Parse command-line options
while getopts "d:w:e:f:" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;
        w) wordlist="$OPTARG" ;;
        e) extract_dir="$OPTARG" ;;
        f) single_file="$OPTARG" ;;
        *) usage ;;
    esac
done

# Test read wordlist
# echo "Reading wordlist from: $wordlist"
# while IFS= read -r password; do
#     echo "Read password: $password"
# done < "$wordlist"

# Validate and set default extract directory if not provided
if [ -z "$extract_dir" ]; then
    extract_dir="./extract"  # Default extraction directory
    echo "No extraction directory provided. Using default: $extract_dir"
    mkdir -p "$extract_dir"
elif [ ! -d "$extract_dir" ]; then
    echo "Creating directory: $extract_dir"
    mkdir -p "$extract_dir"
fi

export extract_dir

# Function to attempt password on a RAR or ZIP file
extract_file() {
    local file="$1"
    local password="$2"
    local output
    local file_type="${file##*.}"

    if [[ "$file_type" == "rar" ]]; then
        echo "Trying Password: $password"
        output=$(unrar x "$file" -p"$password" $extract_dir -y)
        if [[ "$output" == *"All OK"* ]]; then
            echo "Password Found: '$password', For File: $file"
            echo "Extracting $file with password: $password"
            echo ""
            return 0
        else
            return 1
        fi
    elif [[ "$file_type" == "zip" ]]; then
        echo "Trying Password: $password"
        output=$(7z x "$file" "-o$extract_dir" "-p$password" -y 2>&1)
        if [[ $output == *"Wrong password"* ]]; then
            return 1
        elif [[ $output == *"Everything is Ok"* ]]; then
            echo "Password found for $file: '$password'"
            echo "Extracting $file with password: $password"
            echo ""
            return 0
        else
            echo "Error extracting $file with password $password: $output"
            return 1
        fi
    fi
}

# Export the function to be available in parallel execution
export -f extract_file

# Crack a single file if provided
if [ -n "$single_file" ]; then
    echo "Cracking single file: $single_file"
    parallel -j5 --halt now,success=1 extract_file "$single_file" :::: "$wordlist" 2>/dev/null
    exit 0
fi

# Find all RAR and ZIP files in the directory and subdirectories, handling file names with spaces correctly
find "$directory" -type f \( -name "*.rar" -o -name "*.zip" \) -print0 | while IFS= read -r -d '' file; do
    echo "Cracking \"$file\""
    parallel --quote -j5 --halt now,success=1 extract_file "$file" :::: "$wordlist" 2>/dev/null
done
