#!/usr/bin/env bash
cd 'stats'
read -r num < failedAttempts.dat
if [[ "$num" -gt 6 ]]; then
    if [ -x "$(command -v mpv)" ]; then
        mpv https://archive.org/download/TemaDaVitriaAyrtonSenna/TemaDaVitoria-AyrtonSenna.mp3 &
    fi
fi
echo "0" > failedAttempts.dat
