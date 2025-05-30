#!/bin/bash

fortune -n 250 -s | awk -v C="$(tput cols)" '
  { lines[NR] = $0; if (length > max) max = length }
  END {
    ind = int((C - max) / 2); if (ind < 0) ind = 0
    for (i = 1; i <= NR; i++)
      printf("%*s%s\n", ind, "", lines[i])
}'
