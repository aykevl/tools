#!/bin/sh

while true; do
	# Sleep until 04:50:08 (random time at night)
	now=`date +%s`
	next=$(( now / 86400 * 86400 + 86400 + 17408 - now ))
	echo now: $now $next
	sleep $next

	# kill with -9 (otherwise it won't actually exit)
	echo restarting librespot...
	killall -9 librespot-daemon
done
