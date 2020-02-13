#!/bin/bash

set -e

scriptdir=$(dirname "$0")

printf "%s\n" "$scriptdir"

cd "$scriptdir"

git pull || (echo "Not clean merge"; exit 1)

if [[ "$#" -eq 1 ]]; then
    autocorrectfile="$1"
else
    autocorrectfile=~/.autocorrect
fi

printf "attemping to upload the autocorrect file: %s\n" "$autocorrectfile"

if [[ ! -f "$autocorrectfile" ]]; then
    echo "$autocorrectfile does not exist."
    exit 2
fi

prevNumCorrections="$(wc -l < corrections.vim)"
cat "$autocorrectfile" "corrections.vim" | sed 's/\r$//' | sort -u | sort -d -k 3,3 > tmp && mv tmp corrections.vim
num_new_iabbrevs="$(($(wc -l < corrections.vim) - $prevNumCorrections))"
echo "Added $num_new_iabbrevs new iabbrevs into the correction list. $(wc -l < corrections.vim) total."

autocorrectdir=$(dirname "$autocorrectfile")

git commit -am "Add $num_new_iabbrevs iabbrevs"
git push

cp "$autocorrectfile" "$autocorrectdir"/.autocorrect-backup
echo "Created backup at $autocorrectdir/.autocorrect-backup"

# Clear the autocorrect file.
> "$autocorrectfile"
echo "Cleared $autocorrectfile"

