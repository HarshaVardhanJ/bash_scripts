#!/usr/bin/env bash
#
#: Title        :	usb_listing.sh
#: Date         :	15-Aug-2018
#: Author       :	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :	1.0 (Stable)
#: Description  :	This script returns information about any USB
#                	storage devices connected to the machine. This
#					data is stored in an array.
#: Options      :	The 'drive_selector' function takes an optional
#					argument which when given, is assigned to the
#					'PS3' variable.
#: Usage		:	Calling the functions will output the list of
#					either all devices, or devices that are recognised
#					as 'Removable' by the machine. Calling the
#					'drive_selector' function will display a menu from
#					which the user can pick an option which is then
#					printed out.
################

# Source the 'loading_indicator' script. This script provides two functions.
# The first function takes a PID as an argument and displays the loading indicator
# till the process exits/completes.
# The second function just displays the loading indicator and requires no
# arguments.
source ~/GitRepos/bash_scripts/loading_indicator.sh

# Function that provides list of removable USB devices attached to machine
# Output:	
#			disk3	16GB
#			disk4	256GB
function usb_devices_list() {
	system_profiler SPUSBDataType \
		| awk '
			/Capacity:/{c=$2$3}
	        /Removable Media:/{r=$3}
			/BSD Name:/{n=$3}
			/USB Interface:/{printf("%-10s\t%s\t%s\n", n, c, r)}
			' \
		| awk -F '\t' '
			{ if ($3=="Yes"){printf("%-10s\t%s\n", $1, $2)} }
			'
}

# Pretty print information about removable drives attached to the machine
# Output:
#			Drive	Capacity
#			----------------
#			disk3		16GB
#			disk4		256GB
function drive_info_print() {
	# Print header
	printf "\n\n%s\n" "------Drive List-------"
	printf "%-10s\t%s\n" "Drive" "Capacity"
	printf "%s\n" "------------------------"
	usb_devices_list
	printf "%s\n" "------------------------"
	printf "\n"
}

# Populate the ARRAY variable
function drive_array() {
	ARRAY=($(usb_devices_list | awk '{print $1}' | tr '\n' ' '))
}

# Function that prompts user to pick a drive
# Function input	:	Not needed. Optional.
# Function output	:	Device name ("/dev/diskn")
function drive_selector() {
	# If argument is given, assign it to 'PS3' variable.
	# Else, use 'PS3' variable defined in the loop.
	if [ $# -eq 1 ]
	then
		PS3=${1}
	else
		PS3="Pick a drive. Refer to the above list before picking. Enter a number  :  "
	fi

	printf "\n%s" "Looking for drives. If not inserted, please do so now      "

	while true
	do
		# Adding drive list to array
		drive_array

		# If array is empty
		if [[ ${#ARRAY[@]} -eq 0 ]]
		then
			loading_indicator
		# If ARRAY variable has been populated
		elif [[ ${#ARRAY[@]} -gt 0 ]]
		then
			drive_info_print				# Displays capacity and device name of storage media
			select OPTION in "${ARRAY[@]}" 	# Select loop
			do
				break
			done

			# Check if replies match any of the following options
			case "${REPLY}" in
				${#ARRAY[@]})
					printf "\n%s%s\n" "/dev/" "${OPTION}"
					break
					;;
				R|r)
					printf "\n%s\n" "Refreshing device list."
					continue
					;;
				C|c)
					printf "\n%s\n" "Cancelling device selection."
					break
					;;
				H|h)
					# Print selector help text. Create function for that.
					printf "\n%s\n" "Printing help text."
					continue
					;;
				*)
					printf "\n%s\n%s\n" "Incorrect selection. Enter the number beside the device name." "Enter 'h' to print help text"
					continue
					;;
			esac
		fi
	done
}

while true
do
	drive_selector
	if [[ "${OPTION}" =~ disk[0-9] || "${REPLY}" =~ [cC] ]]
	then
		break 2
#	else
#		sleep 0.5
#		continue
	fi
done
