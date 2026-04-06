#!/usr/bin/env bash
# Extract clean transcript text from a YouTube video
# Usage: transcript.sh <youtube-url> [language]
set -euo pipefail

URL="${1:?Usage: transcript.sh <youtube-url> [language]}"
LANG="${2:-en}"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "--- Video Info ---"
yt-dlp --dump-json "$URL" 2>/dev/null | python3 -c "
import json,sys
try:
    d=json.load(sys.stdin)
    print(f'Title: {d.get(\"title\",\"?\")}')
    print(f'Channel: {d.get(\"channel\",\"?\")}')
    print(f'Duration: {d.get(\"duration\",0)//60}m{d.get(\"duration\",0)%60}s')
    print(f'Upload: {d.get(\"upload_date\",\"?\")}')
except: print('Could not parse metadata')
" 2>/dev/null || true

echo ""
echo "--- Transcript ---"

# Try manual subs first, then auto-generated
yt-dlp --write-sub --write-auto-sub --sub-lang "$LANG" --sub-format vtt \
    --skip-download -o "$TMPDIR/%(id)s" "$URL" 2>/dev/null

# Find the subtitle file
SUB_FILE=$(find "$TMPDIR" -name "*.vtt" -o -name "*.srt" | head -1)

if [ -z "$SUB_FILE" ]; then
    echo "No subtitles found for language: $LANG"
    echo "Try: yt-dlp --list-subs '$URL' to see available languages"
    exit 1
fi

# Clean VTT/SRT to plain text (remove timestamps, headers, duplicates)
python3 -c "
import re, sys

with open('$SUB_FILE', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove VTT header
content = re.sub(r'^WEBVTT.*?\n\n', '', content, flags=re.DOTALL)
# Remove timestamp lines
content = re.sub(r'\d{2}:\d{2}:\d{2}[\.,]\d{3}\s*-->.*\n', '', content)
# Remove sequence numbers
content = re.sub(r'^\d+\s*$', '', content, flags=re.MULTILINE)
# Remove VTT positioning tags
content = re.sub(r'<[^>]+>', '', content)
# Remove alignment tags
content = re.sub(r'align:.*|position:.*|line:.*', '', content)

# Deduplicate consecutive identical lines
lines = [l.strip() for l in content.splitlines() if l.strip()]
deduped = []
for line in lines:
    if not deduped or line != deduped[-1]:
        deduped.append(line)

print('\n'.join(deduped))
"
