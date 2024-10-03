#!/bin/bash

# Check the number of arguments
if [ "$#" -eq 0 ]; then
    echo "No folder names provided."
    exit 1
fi

# Loop through each argument
for dir in "$@"; do
    if [ ! -d "$dir" ]; then
        mkdir "$dir"
    fi
done

