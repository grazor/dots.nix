#!/usr/bin/env bash

set -e

export DISPLAY=':0'

LOCKFILE="/tmp/d2unpause.lock"
PID=0

if ! touch "$LOCKFILE.$$" ; then
	echo "failed to create PID lockfile: $1" 1>&2
	exit 1
fi

if ! ln -s "$LOCKFILE.$$" "$LOCKFILE" 2>/dev/null; then
	PID=$(readlink $LOCKFILE | cut -d '.' -f 3)
else 
	trap 'rm -f "$LOCKFILE" "$LOCKFILE.$$"' EXIT
fi


if [ $PID -eq 0 ] ; then
	while true; do
		xdotool key F9
		sleep 1
	done
else
	kill $PID
fi


