
#!/bin/bash

# Set the target CRF and resolution scaling for AV1 encoding
CRF=30
SCALE=1080

# Function to convert image files to AVIF
convert_to_avif() {
    local file="$1"
    local filename="${file%.*}"  # Remove the extension to get the base name
    local extension="${file##*.}"  # Get the file extension

    # Check if the file is an image (you can add more extensions if needed)
    if [[ "$extension" == "jpg" || "$extension" == "png" ]]; then
        echo "Converting $file to ${filename}.avif"

        # Use ffmpeg to convert the image to AVIF format
        ffmpeg -i "$file" -vf "scale=${SCALE}:-1" -c:v libaom-av1 -crf "$CRF" -b:v 0 "${filename}.avif"
        
        # Check if conversion was successful
        if [ $? -eq 0 ]; then
            echo "Conversion successful: ${filename}.avif"
        else
            echo "Error converting $file"
        fi
    fi
}

# Export the function for use in subshells and find command
export -f convert_to_avif
export CRF SCALE

# Recursively find all image files in the current directory and subdirectories and convert them
find . -type f -exec bash -c 'convert_to_avif "$0"' {} \;

echo "All conversions completed."

