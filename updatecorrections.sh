#!/bin/bash

cat ~/.autocorrect corrections.vim | sort -u | sort -f -k 3,3 > tmp && mv tmp corrections.vim
echo "Added $(cat ~/.autocorrect | wc -l) new iabbrevs into the correction list. $(cat corrections.vim | wc -l) total."

cp ~/.autocorrect ~/.autocorrect-backup
echo "Created backup at ~/.autocorrect-backup"

# Clear the autocorrect file.
> ~/.autocorrect
echo "Cleared ~/.autocorrect"
