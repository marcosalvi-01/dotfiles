#!/bin/bash

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

# Check if identify (ImageMagick) is installed
if ! command -v identify &> /dev/null; then
    echo "Error: ImageMagick is not installed. Please install it first."
    exit 1
fi

# Check if gowall is installed
if ! command -v gowall &> /dev/null; then
    echo "Error: gowall is not installed. Please install it first."
    exit 1
fi

# Target dimensions
TARGET_WIDTH=3440
TARGET_HEIGHT=1440

# Process each image in the directory
find "$DIR_PATH" -type f -exec file {} \; | grep -i "image" | cut -d: -f1 | while read -r image; do
    # Get image dimensions
    dimensions=$(identify -format "%wx%h" "$image" 2>/dev/null)
    if [ $? -eq 0 ]; then
        width=$(echo $dimensions | cut -d'x' -f1)
        height=$(echo $dimensions | cut -d'x' -f2)
        
        echo "Processing: $image ($width x $height)"
        
        # Check if dimensions are less than target
        if [ "$width" -lt "$TARGET_WIDTH" ] || [ "$height" -lt "$TARGET_HEIGHT" ]; then
            # Calculate required scaling factors for both dimensions
            width_scale=$(echo "scale=2; $TARGET_WIDTH / $width" | bc)
            height_scale=$(echo "scale=2; $TARGET_HEIGHT / $height" | bc)
            
            # Use the larger scaling factor to ensure both dimensions meet or exceed target
            scale_factor=$(echo "$width_scale $height_scale" | tr ' ' '\n' | sort -nr | head -n1)
            
            # Round up to nearest valid scale factor (2, 3, or 4)
            if (( $(echo "$scale_factor <= 2" | bc -l) )); then
                final_scale=2
            elif (( $(echo "$scale_factor <= 3" | bc -l) )); then
                final_scale=3
            else
                final_scale=4
            fi
            
            echo "Required scaling factor: $scale_factor, using scale: $final_scale"
            
            # Use realesrgan-x4plus model for best quality
            echo "Upscaling with realesrgan-x4plus model..."
            if [ $final_scale -eq 4 ]; then
                # For scale 4, we don't need to specify -s as the model forces it
                gowall upscale "$image" --model realesrgan-x4plus
            else
                # For other scales, we need to specify both model and scale
                gowall upscale "$image" --model realesrgan-x4plus --scale $final_scale
            fi
            
            if [ $? -eq 0 ]; then
                echo "Successfully upscaled: $image"
            else
                echo "Failed to upscale: $image"
            fi
        else
            echo "Image meets dimension requirements, skipping..."
        fi
    else
        echo "Failed to get dimensions for: $image"
    fi
done

echo "Processing complete!"
