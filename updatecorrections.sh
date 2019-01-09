#!/bin/bash

set -e

scriptdir=$(dirname "$0")

cd "$scriptdir"

git pull || (echo "Not clean merge"; exit 1)

if [[ "$#" -eq 1 ]]; then
    autocorrectfile="$1"
else
    autocorrectfile=~/.autocorrect
fi

if [[ ! -f "$autocorrectfile" ]]; then
    echo "$autocorrectfile does not exist."
    exit 2
fi

cat "$autocorrectfile" "corrections.vim" | sed 's/\r$//' | sort -u | sort -d -k 3,3 > tmp && mv tmp corrections.vim
echo "Added $(cat "$autocorrectfile" | wc -l) new iabbrevs into the correction list. $(cat corrections.vim | wc -l) total."

autocorrectdir=$(dirname "$autocorrectfile")

git commit -am "Add iabbrevs"
git push

cp "$autocorrectfile" "$autocorrectdir"/.autocorrect-backup
echo "Created backup at "$autocorrectdir"/.autocorrect-backup"

# Clear the autocorrect file.
> "$autocorrectfile"
echo "Cleared $autocorrectfile"

