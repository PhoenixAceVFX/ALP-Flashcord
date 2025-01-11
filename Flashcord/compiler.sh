#!/bin/bash

File_Name="sid.css"

# Logging system + getting current time and date in preferred format
GetTime() {
    local Time Date
    Time=$(date +"%H:%M:%S")
    Date=$(date +"%d/%m/%Y")
    echo "$Time" "$Date"
}

WriteLog() {
    local Time Date Log
    read -r Time Date <<< "$(GetTime)"
    Log="[$Time - $Date] $1"
    echo "$Log"
}

ls_css_files() {
    local Path Files Temp
    Path=$(pwd)
    Files=()

    # Find all .css files excluding main.css and sid.css
    while IFS= read -r -d '' File; do
        Temp=$(realpath --relative-to="$Path" "$File")
        Files+=("$Temp")
    done < <(find "$Path" -type f -name "*.css" -print0)

    # Exclude specific files
    Files=("${Files[@]/main.css}")
    Files=("${Files[@]/$File_Name}")

    # Sort the files alphanumerically
    printf "%s\n" "${Files[@]}" | sort
}

Build_Date() {
    local Time Date Build_Date Build_String
    read -r Time Date <<< "$(GetTime)"
    Build_Date="\"$Time - $Date\""
    Build_String="\n:root { --FlashCore-Build_Date: $Build_Date; }"
    echo -e "$Build_String"
}

Flashcord_Compiler() {
    WriteLog "Parsing CSS files..."
    CSS_Files=($(ls_css_files))
    WriteLog "Parsed the following files (sorted): ${CSS_Files[*]}"

    {
        for CSS_File in "${CSS_Files[@]}"; do
            if [[ -f "$CSS_File" ]]; then
                cat "$CSS_File"
            else
                WriteLog "Warning: File '$CSS_File' not found!"
            fi
        done
        Build_Date
    } > "$File_Name" && WriteLog "Flashcord has been compiled successfully!" || \
    WriteLog "ERROR COMPILING FLASHCORD"
}

# Main execution
Flashcord_Compiler
