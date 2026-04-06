---
name: youtube-transcript
description: Extract subtitles and transcripts from YouTube videos using yt-dlp. Use when asked to transcribe a YouTube video, get video captions, extract what was said in a video, summarize a YouTube video's spoken content, or get video metadata. Supports auto-generated and manual subtitles in any language.
---

# YouTube Transcript Extractor

Wraps `yt-dlp` to extract clean transcripts from YouTube videos.

## Quick Start

```bash
# Extract transcript as clean text
scripts/transcript.sh "https://www.youtube.com/watch?v=VIDEO_ID"

# Specify language (default: en)
scripts/transcript.sh "https://www.youtube.com/watch?v=VIDEO_ID" id
```

## Manual Commands

### Get video metadata (JSON)
```bash
yt-dlp --dump-json "URL" | python3 -c "
import json,sys; d=json.load(sys.stdin)
print(f'Title: {d[\"title\"]}')
print(f'Channel: {d[\"channel\"]}')
print(f'Duration: {d[\"duration\"]}s')
print(f'Views: {d.get(\"view_count\",\"?\")}')
print(f'Upload: {d[\"upload_date\"]}')
"
```

### List available subtitles
```bash
yt-dlp --list-subs "URL"
```

### Download subtitles only
```bash
yt-dlp --write-sub --write-auto-sub --sub-lang en --skip-download -o "%(title)s" "URL"
```

## Output

The transcript script outputs clean text with timestamps stripped. For raw subtitle files (VTT/SRT), use the manual commands above.

## Notes

- Auto-generated captions are available for most videos
- Quality varies — auto-captions can have errors
- Some videos have no captions at all
- Works with YouTube shorts, playlists (first video), and live streams (if archived)
- yt-dlp must be installed (check: `which yt-dlp`)
