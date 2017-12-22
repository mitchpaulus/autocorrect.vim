#!/bin/bash
cat ~/.autocorrect corrections.vim | sort -u | sort -f -k 3,3 > corrections.vim


