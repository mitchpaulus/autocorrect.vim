#!/bin/bash

set -e

if [[ "$#" -eq 1 ]]; then
    autocorrectfile="$1"
else
    autocorrectfile="~/.autocorrect"
fi

if [[ ! -f "$autocorrectfile" ]]; then
    echo "$autocorrectfile does not exist."
    exit 0
fi

cat "$autocorrectfile" "corrections.vim" | sed 's/\r$//' | sort -u | sort -f -k 3,3 > tmp && mv tmp corrections.vim
echo "Added $(cat "$autocorrectfile" | wc -l) new iabbrevs into the correction list. $(cat corrections.vim | wc -l) total."

cp "$autocorrectfile" $(dirname "$autocorrectfile")/.autocorrect-backup
echo "Created backup at $autocorrectfile/.autocorrect-backup"

# Clear the autocorrect file.
> "$autocorrectfile"
echo "Cleared $autocorrectfile"
