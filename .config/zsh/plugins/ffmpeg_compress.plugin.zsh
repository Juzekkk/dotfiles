# ffmpeg_compress.plugin.zsh

ffmpeg_compress() {
    # 1. Check for required tools
    if ! command -v ffmpeg &> /dev/null || ! command -v ffprobe &> /dev/null; then
        echo "❌ Error: ffmpeg and ffprobe are required."
        return 1
    fi

    # 2. Check usage
    if [[ $# -eq 0 ]]; then
        echo "Usage: ffmpeg_compress <inputs...> [output_dir] [size]"
        echo "Example: ffmpeg_compress file.mp4 50MB"
        echo "Example: ffmpeg_compress file.mp4 /tmp/output_folder"
        echo "Example: ffmpeg_compress ./videos/ /backups/ 100MB"
        return 1
    fi

    # --- ARGUMENT PARSING START ---
    local args=("$@")
    local target_size_str="20MB" # Default Size
    local output_dir=""          # Default Output (Source directory)
    
    # Step A: Check for Size (Last argument)
    local last_arg="${args[-1]}"
    if [[ "$last_arg" =~ ^[0-9]+(MB|KB|GB)$ ]]; then
        target_size_str="$last_arg"
        args=("${(@)args[1,-2]}") # Remove last arg
    fi

    # Step B: Check for Output Directory (New last argument)
    # We only assume it's an output dir if we have at least 2 args remaining.
    # If we only have 1 arg (e.g. 'ffmpeg_compress foldername'), that must be the input.
    if [[ ${#args[@]} -ge 2 ]]; then
        local potential_dir="${args[-1]}"
        if [[ -d "$potential_dir" ]]; then
            output_dir="$potential_dir"
            args=("${(@)args[1,-2]}") # Remove last arg
        fi
    fi

    local inputs=("${args[@]}")
    # --- ARGUMENT PARSING END ---

    # Parse target size into bytes
    local target_bytes
    if [[ "$target_size_str" =~ ^([0-9]+)MB$ ]]; then
        target_bytes=$(( ${match[1]} * 1024 * 1024 ))
    elif [[ "$target_size_str" =~ ^([0-9]+)KB$ ]]; then
        target_bytes=$(( ${match[1]} * 1024 ))
    elif [[ "$target_size_str" =~ ^([0-9]+)GB$ ]]; then
        target_bytes=$(( ${match[1]} * 1024 * 1024 * 1024 ))
    fi

    local audio_bitrate_k=128
    local audio_bitrate=$(( audio_bitrate_k * 1000 ))

    # Core processing function
    _ffmpeg_process_item() {
        local file="$1"
        local max_bytes="$2"
        local out_dir_pref="$3"

        if [[ ! -f "$file" ]]; then
            echo "⚠️  '$file' is not a file. Skipping."
            return
        fi

        local base_name=$(basename "$file")
        local final_output_file
        
        # Determine output path
        if [[ -n "$out_dir_pref" ]]; then
            # Output dir was specified
            final_output_file="${out_dir_pref}/compressed_${base_name}"
        else
            # Output dir not specified, use source dir
            local src_dir=$(dirname "$file")
            final_output_file="${src_dir}/compressed_${base_name}"
        fi

        # Get duration
        local duration
        duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file")
        
        if [[ -z "$duration" ]]; then
            echo "⚠️  Could not read duration: '$base_name'. Skipping."
            return
        fi

        # Calculate bitrate
        local video_bitrate
        video_bitrate=$(awk -v size="$max_bytes" -v dur="$duration" -v audio="$audio_bitrate" 'BEGIN { printf "%.0f", ((size * 8) / dur) - audio }')

        if (( video_bitrate < 50000 )); then
             echo "⚠️  Target size ($target_size_str) is too small for '$base_name'. Skipping."
            return
        fi

        echo "🎬 Processing '$base_name'..."
        echo "   Target: $target_size_str | Output: $final_output_file"

        # Pass 1 (-y to overwrite logs)
        ffmpeg -y -i "$file" -c:v libx264 -b:v "$video_bitrate" -pass 1 -an -f null /dev/null -hide_banner -loglevel error
        
        # Pass 2 (-y to overwrite output)
        ffmpeg -y -i "$file" -c:v libx264 -b:v "$video_bitrate" -pass 2 -c:a aac -b:a "${audio_bitrate_k}k" "$final_output_file" -hide_banner -loglevel error

        rm -f ffmpeg2pass-0.log ffmpeg2pass-0.log.mbtree
        echo "✅ Done."
    }

    # Main Loop
    for input in "${inputs[@]}"; do
        if [[ -d "$input" ]]; then
            echo "📂 Scanning input folder: $input"
            find "$input" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.webm" \) | while read -r video_file; do
                _ffmpeg_process_item "$video_file" "$target_bytes" "$output_dir"
            done
        else
            _ffmpeg_process_item "$input" "$target_bytes" "$output_dir"
        fi
    done
}
