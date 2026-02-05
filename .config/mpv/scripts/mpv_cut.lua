---@diagnostic disable: lowercase-global, undefined-global

local msg = require("mp.msg")
local utils = require("mp.utils")

-- ============================================================================
-- Configuration
-- ============================================================================

local settings = {
    key_mark_cut = "c",
    video_extension = "mp4",
    output_path = "",
    ffmpeg_params = "",

    youtube = {
        output_path = os.getenv("HOME") .. "/clips/yt",
        ytdlp_path = "/usr/bin/yt-dlp",
    },

    web = {
        key_mark_cut = "shift+c",
        audio_bitrate = 128,
        target_filesize = 7.50,
        scale = "1280:-1",
    },
}

-- ============================================================================
-- State
-- ============================================================================

local state = {
    path = nil,
    filename = nil,
    directory = nil,
    is_web_mode = false,
    is_youtube = false,
    start_pos = nil,
    end_pos = nil,
}

-- ============================================================================
-- Path Utilities
-- ============================================================================

local function normalize_path(path)
    if not path then return "" end
    return path:gsub("[\\/]+$", "")
end

local function get_base_name(filename, ext)
    return filename:gsub("%." .. ext .. "$", "")
end

local function sanitize_filename(name)
    -- Remove/replace characters that are problematic in filenames
    return name
        :gsub('[<>:"/\\|?*]', "_")
        :gsub("%s+", "_")
        :gsub("_+", "_")
        :gsub("^_+", "")
        :gsub("_+$", "")
end

local function ensure_directory(path)
    local info = utils.file_info(path)
    if not info then
        local result = os.execute('mkdir -p "' .. path .. '"')
        if not result then
            msg.error("Failed to create directory: " .. path)
            return false
        end
        msg.info("Created directory: " .. path)
    end
    return true
end

local function get_unique_filename(dir, filename, ext)
    dir = normalize_path(dir)
    local base = get_base_name(filename, ext)
    local index = 1
    local new_path

    repeat
        new_path = string.format("%s/COPY_%d_%s.%s", dir, index, base, ext)
        index = index + 1
    until not utils.file_info(new_path)

    return new_path
end

local function is_url(path)
    return path:match("^https?://") or path:match("^ytdl://")
end

-- ============================================================================
-- Utilities
-- ============================================================================

local function format_timestamp(seconds)
    local hrs = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    local ms = math.floor((seconds % 1) * 1000)
    return string.format("%02d:%02d:%02d.%03d", hrs, mins, secs, ms)
end

local function format_timestamp_short(seconds)
    -- For filenames: MM-SS format
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d-%02d", mins, secs)
end

local function log_to_file(message)
    local f = io.open("mpv-cut.log", "a")
    if f then
        f:write(message .. "\n")
        f:close()
    end
end

local function notify(level, message, osd_seconds, write_log)
    level(message)
    if osd_seconds and osd_seconds > 0 then
        mp.osd_message(message, osd_seconds)
    end
    if write_log then
        log_to_file(message)
    end
end

local function run_command(args)
    msg.info("Executing: " .. table.concat(args, " "))
    local result = mp.command_native({
        name = "subprocess",
        args = args,
        capture_stdout = true,
        capture_stderr = true,
        playback_only = false,
    })
    msg.info("Finished: " .. args[1])
    return result.status, result.stdout, result.stderr
end

local function reset_state()
    state.start_pos = nil
    state.end_pos = nil
end

local function cleanup_files(files)
    for _, path in ipairs(files) do
        local ok, err = os.remove(path)
        if ok then
            msg.info("Deleted: " .. path)
        else
            msg.warn("Failed to delete " .. path .. ": " .. (err or ""))
        end
    end
end

-- ============================================================================
-- FFmpeg Operations
-- ============================================================================

local function ffmpeg_cut(input, output, time_start, time_end)
    local cmd

    if settings.ffmpeg_params ~= "" and not state.is_web_mode then
        cmd = {"ffmpeg", "-async", "1", "-y", "-i", input}
        for param in settings.ffmpeg_params:gmatch("%S+") do
            table.insert(cmd, param)
        end
        for _, v in ipairs({"-ss", time_start, "-to", time_end, output}) do
            table.insert(cmd, v)
        end
    else
        cmd = {
            "ffmpeg", "-async", "1", "-y",
            "-ss", time_start, "-to", time_end,
            "-i", input,
            "-c:v", "copy", "-c:a", "aac", "-b:a", "320k",
            output,
        }
    end

    local status, _, stderr = run_command(cmd)
    if status > 0 then
        local err = (stderr or ""):gsub("^%s*(.-)%s*$", "%1")
        notify(msg.error, err, nil, true)
        return false
    end
    return true
end

local function ffmpeg_resize(input, output, duration)
    local video_bitrate = ((settings.web.target_filesize * 8192) / duration) - settings.web.audio_bitrate

    if video_bitrate <= 0 then
        notify(msg.error, "Target bitrate too low!", 10)
        return false
    end

    local bitrate_str = string.format("%dk", math.floor(video_bitrate))
    local scale = settings.web.scale == "original" and "scale=iw:ih" or ("scale=" .. settings.web.scale)
    local audio_br = string.format("%dk", settings.web.audio_bitrate)

    msg.info("Target bitrate: " .. bitrate_str)

    -- Pass 1
    local status, _, stderr = run_command({
        "ffmpeg", "-async", "1", "-y", "-i", input,
        "-c:v", "libx264", "-vf", scale, "-b:v", bitrate_str,
        "-pass", "1", "-an", "-f", "rawvideo", "NUL",
    })
    if status > 0 then
        notify(msg.error, (stderr or ""):gsub("^%s*(.-)%s*$", "%1"), nil, true)
        return false
    end

    -- Pass 2
    status, _, stderr = run_command({
        "ffmpeg", "-async", "1", "-y", "-i", input,
        "-c:v", "libx264", "-vf", scale, "-b:v", bitrate_str,
        "-pass", "2", "-c:a", "aac", "-b:a", audio_br, output,
    })
    if status > 0 then
        notify(msg.error, (stderr or ""):gsub("^%s*(.-)%s*$", "%1"), nil, true)
        return false
    end

    return true
end

-- ============================================================================
-- YouTube Download
-- ============================================================================

local function ytdlp_download_clip(url, output, time_start, time_end)
    local cmd = {
        settings.youtube.ytdlp_path,
        "--no-warnings",
        "-f", "bestvideo+bestaudio/best",
        "--download-sections", string.format("*%s-%s", time_start, time_end),
        "--force-keyframes-at-cuts",
        "--merge-output-format", settings.video_extension,
        "-o", output,
        url,
    }

    local status, _, stderr = run_command(cmd)
    if status > 0 then
        local err = (stderr or ""):gsub("^%s*(.-)%s*$", "%1")
        notify(msg.error, err, nil, true)
        return false
    end
    return true
end

-- ============================================================================
-- Main Logic
-- ============================================================================

function mark_pos()
    local pos = mp.get_property_number("time-pos")
    if not pos then
        notify(msg.error, "Cannot get playback position", 3)
        return
    end

    -- First press: mark start
    if not state.start_pos then
        state.start_pos = pos
        notify(msg.info, "Start: " .. format_timestamp(pos), 3)
        return
    end

    -- Second press: mark end and cut
    state.end_pos = pos

    if state.start_pos >= state.end_pos then
        notify(msg.error, "End must be after start!", 3)
        reset_state()
        return
    end

    local duration = state.end_pos - state.start_pos
    notify(msg.info, "End: " .. format_timestamp(pos), 3)

    local output

    if state.is_youtube then
        -- YouTube: use yt-dlp to download clip directly
        if not ensure_directory(settings.youtube.output_path) then
            notify(msg.error, "Cannot create output directory!", 10)
            reset_state()
            return
        end

        local timestamp = format_timestamp_short(state.start_pos) .. "_" .. format_timestamp_short(state.end_pos)
        local safe_filename = sanitize_filename(state.filename)
        local base_output = string.format("%s/%s_%s.%s",
            normalize_path(settings.youtube.output_path),
            safe_filename,
            timestamp,
            settings.video_extension
        )

        -- Find unique filename
        output = base_output
        local index = 1
        while utils.file_info(output) do
            output = string.format("%s/%s_%s_%d.%s",
                normalize_path(settings.youtube.output_path),
                safe_filename,
                timestamp,
                index,
                settings.video_extension
            )
            index = index + 1
        end

        msg.info("Output: " .. output)
        notify(msg.info, "Downloading clip...", 5)

        if not ytdlp_download_clip(state.path, output, format_timestamp(state.start_pos), format_timestamp(state.end_pos)) then
            notify(msg.error, "Download failed! Check log.", 10)
            reset_state()
            return
        end
    else
        -- Local file: use ffmpeg
        local output_dir = settings.output_path ~= "" and settings.output_path or state.directory
        output = get_unique_filename(output_dir, state.filename, settings.video_extension)

        msg.info("Output: " .. output)

        if not ffmpeg_cut(state.path, output, format_timestamp(state.start_pos), format_timestamp(state.end_pos)) then
            notify(msg.error, "Cut failed! Check log.", 10)
            reset_state()
            return
        end

        -- Web mode: resize
        if state.is_web_mode then
            notify(msg.info, "Encoding for web...", 10)
            local resized = get_unique_filename(output_dir, state.filename, settings.video_extension)

            if not ffmpeg_resize(output, resized, duration) then
                notify(msg.error, "Resize failed! Check log.", 10)
                reset_state()
                return
            end

            cleanup_files({output, "ffmpeg2pass-0.log", "ffmpeg2pass-0.log.mbtree"})
            output = resized
        end
    end

    notify(msg.info, "Saved: " .. output, 10)
    reset_state()
    state.is_web_mode = false
    mp.set_property("keep-open", "no")
end

function web_mark_pos()
    state.is_web_mode = true
    mark_pos()
end

-- ============================================================================
-- Events & Bindings
-- ============================================================================

mp.register_event("file-loaded", function()
    local path = mp.get_property("path")
    local dir, filename = utils.split_path(path)

    state.path = path
    state.directory = dir
    state.is_youtube = is_url(path)

    if state.is_youtube then
        -- For YouTube, use media-title which yt-dlp provides
        state.filename = mp.get_property("media-title") or "youtube_clip"
        msg.info("YouTube video detected: " .. state.filename)
    else
        state.filename = mp.get_property("filename")
    end

    mp.set_property("keep-open", "always")
    msg.info("Loaded: " .. path)
end)

mp.add_key_binding(settings.key_mark_cut, "mark_pos", mark_pos)
mp.add_key_binding(settings.web.key_mark_cut, "web_mark_pos", web_mark_pos)

msg.info("mpv-cut loaded")
