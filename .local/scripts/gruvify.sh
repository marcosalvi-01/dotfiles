#!/bin/sh

# Check if a directory path is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Store the directory path
DIR_PATH="$1"

# Check if the directory exists
if [ ! -d "$DIR_PATH" ]; then
    echo "Error: Directory does not exist"
    exit 1
fi

# Check if gowall is installed
if ! command -v gowall &> /dev/null; then
    echo "Error: gowall is not installed. Please install it first."
    exit 1
fi

# Process each image in the directory
find "$DIR_PATH" -type f -exec file {} \; | grep -i "image" | cut -d: -f1 | while read -r image; do
    echo "Processing: $image"

    # Run gowall convert with gruvbox theme
    gowall convert "$image" --theme gruvbox

    if [ $? -eq 0 ]; then
        echo "Successfully converted: $image"
    else
        echo "Failed to convert: $image"
    fi
done

echo "Processing complete!"
