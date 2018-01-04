#!/usr/bin/env bash
cd 'stats'
oldnum=`cut -d ',' -f2 failedAttempts.dat` || 0
newnum=`expr $oldnum + 1`
sed -i "s/$oldnum\$/$newnum/g" failedAttempts.dat
