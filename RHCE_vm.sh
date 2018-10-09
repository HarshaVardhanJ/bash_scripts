#!/usr/bin/env bash
#
#: Title        :	RHCE_vm.sh
#: Date         :	14-Sep-2018
#: Author       :	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :	2.0 (Stable)
#: Description  :	If given the argument 'on', this script first 
#                   starts the VM tagged as "RHCE", then it pings the 
#                   VM to check if it is up, then it tries to SSH into 
#                   the VM until it gains access.
#                   If given the argument 'off', this script turns off
#                   the VM tagged as "RHCE", if it running.
#: Options      :	One required. Either 'on' or 'off'
#: Usage		:	Call the script. One argument needed.
#					Example: ./RHCE_vm.sh on
#                            ./RHCE_vm.sh off
################

# Import the 'loading_indicator.sh' script
source ~/GitRepos/bash_scripts/loading_indicator.sh

# Function to control state of VM, depending on the argument given to the script
# If the 'on' argument is given, this function starts the VM
# If the 'off' argument is given, this function turns off the VM
function control_vm() {
	# UUID of 'RHCE' VM
	local -r UUID="80fc2908-3ee6-4196-85d3-b7f484e883dc"

	# If the argument is "on"
	if [[ "${FLAG}" == "on" ]]
	then
		# If RHCE VM is running, print that it's on
		if [[ $( VBoxManage list runningvms ) =~ ${UUID} ]]
		then
			printf '\n%s\n' "VM is running"
		# If RHCE VM isn't running, turn it on
		elif [[ ! $( VBoxManage list runningvms ) =~ ${UUID} ]]
		then
			VBoxManage startvm --type headless "${UUID}" 1>/dev/null 2>&1
			printf '%s\n' "VM powered on"
		fi
	# If the argument is "off"
	elif [[ "${FLAG}" == "off" ]]
	then
		# If RHCE VM is running, turn it off
		if [[ $( VBoxManage list runningvms ) =~ ${UUID} ]]
		then
			printf '\n%s\n' "VM is running. Stopping VM..."
			VBoxManage controlvm "${UUID}" poweroff
		# If RHCE VM is not running, print that it's off
		else
			printf '\n%s\n' "VM is not running."
		fi
	fi
}

# Function to check if VM is responding to pings
function ping_vm() {
	# IP Address of RHCE VM (Local variable)
	# The '-g' option needs to be used because 'declare'
	# creates a local variable when used within a function.
	# Using the '-g' flag overrides this. Check 'help declare'
	# for reference.
	local -r IP="192.168.1.60"
	local -r END_TIME=$((${SECONDS}+30))

	printf '\n%s\n' "Trying to ping VM"

	# Keep executing sleep command until ping command succeeds or until 30 seconds are up
	until ping -c1 "${IP}" 1>/dev/null 2>&1 # Can also be written as &>/dev/null
	do
		loading_indicator

		# If time exceeds 30 seconds, exit.
		if [[ ${SECONDS} -gt ${END_TIME} ]]
		then
			printf '\n%s\n' "VM has not responded to ICMP echo requests for 30 seconds. Exiting script."
			exit 1
		fi
	done
}


# Function to check if SSH port is open and is accepting connections
function ssh_port() {
	local -r IP="192.168.1.60"

	# If VM is running and is responding to ICMP echo requests
	if control_vm && ping_vm
	then
		printf '\n%s\n' "VM is responding to ICMP echo requests"
		# Check if VM is accepting connections on port 22
		until nc -z "${IP}" 22 1>/dev/null 2>&1
		do
#			sleep 2
			loading_indicator
		done
	fi
}


# Function to check if SSH connections are successful
function ssh_login() {
	# If VM is accepting connections on port 22
	if ssh_port
	then
		# Until the VM responds with an 'uptime' report, sleep for 5 seconds
		printf '\n%s\n' "The SSH port for the VM is open and accepting connections"
		until [[ $(ssh -q rhce uptime) =~ "load average" ]]
		do
#			sleep 5
			loading_indicator
		done
	fi
}


# Function to check if argument provided to the script is as defined
function check_input() {
	if [[ $# -eq 1 ]]
	then
		case "${1}" in
			"on")
				FLAG="${1}"
				return
				;;
			"off")
				FLAG="${1}"
				return
				;;
			*)
				printf '\n%s\n\t%s\n\t%s\n' " $0 : Incorrect argument." "USAGE: $0 off" "USAGE: $0 on"
				exit 1
				;;
		esac
	else
		printf '\n%s\n\t%s\n\t%s\n' " $0 : Incorrect number of arguments." "USAGE: $0 off" "USAGE: $0 on"
		exit 1
	fi
}

# Check the input given to the script
check_input "$@"

# The argument given is 'on'
if [[ "${FLAG}" == "on" ]]
then
	# If SSH connections can be made, start an SSH session
	if ssh_login
	then
		printf '\n%s\n\n' "VM can be accessed via SSH. Logging in..."
		ssh -q rhce
	fi
# If the argument given is 'off'
elif [[ "${FLAG}" == "off" ]]
then
	# Turn off the VM
	control_vm
fi

# End of script
