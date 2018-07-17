#!/bin/bash
#
# Script to test function that checks if any USB device has been inserted

function usb_check () {

	# If the number of arguments passed is one and equal to a number
	if [[ $# -eq 1 && $# =~ ^[0-9]+([.][0-9]) ]]
	then
		TIME=$1
	else
		TIME='0.5'
	fi

#	until [[ "$( system_profiler SPUSBDataType )" =~ "BSD Name" ]]
#	do
#		sleep "${TIME}"
#	done

	while true
	do
		if [[ "$( system_profiler SPUSBDataType )" =~ "BSD Name" ]]
		then
			USB="$( system_profiler SPUSBDataType | grep "BSD Name" | cut -d":" -f2 | tr -d ' ' )"
			printf '%s' "${USB}" && return
		else
			# If the number of arguments passed is one and equal to a number
#			if [[ $# -eq 1 && $# =~ ^[0-9]+([.][0-9]) ]]
#			then
#				TIME=$1
#			else
#				TIME='0.5'
#			fi

			sleep "${TIME}"
#			until [[ "$( system_profiler SPUSBDataType )" =~ "BSD Name" ]]
#			do
#				sleep "${TIME}"
#			done
		fi
	done
}

usb_check $1
