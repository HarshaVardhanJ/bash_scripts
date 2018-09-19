#!/usr/bin/env bash
#
#: Title        :	RHCE_vm.sh
#: Date         :	14-Sep-2018
#: Author       :	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :	1.0 (Stable)
#: Description  :	This script first starts the VM tagged as "RHCE",
#              		then it pings the VM to check if it is up, then
#                	it tries to SSH into the VM until it gains access.
#: Options      :	None required. None accepted.
#: Usage		:	Call the script. No arguments needed.
#					Example: ./RHCE_vm.sh
################



# Function to check if VM is running, and run it in case it is not.
function start_vm() {
	# UUID of 'RHCE' VM
	local -r UUID="80fc2908-3ee6-4196-85d3-b7f484e883dc"

	# If RHCE VM is running
	if [[ $( VBoxManage list runningvms ) =~ ${UUID} ]]
	then
		printf '\n%s\n' "VM is running"
	else
		VBoxManage startvm --type headless "${UUID}" 1>/dev/null 2>&1 \
			printf '%s\n' "VM powered on"
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

	# Keep executing sleep command until ping command succeeds
	until ping -c1 "${IP}" 1>/dev/null 2>&1 # Can also be written as &>/dev/null
	do
		sleep 2
	done
}


# Function to check if SSH port is open and is accepting connections
function ssh_port() {
	local -r IP="192.168.1.60"

	# If VM is running and is responding to ICMP echo requests
	if start_vm && ping_vm
	then
		# Check if VM is accepting connections on port 22
		until nc -z "${IP}" 22 1>/dev/null 2>&1
		do
			sleep 2
		done
	fi
}


# Function to check if SSH connections are successful
function ssh_login() {
	# If VM is accepting connections on port 22
	if ssh_port
	then
		# Until the VM responds with an 'uptime' report, sleep for 5 seconds
		until [[ $(ssh -q rhce uptime) =~ "load average" ]]
		do
			sleep 5
		done
	fi
}

# If SSH connections can be made, start an SSH session
if ssh_login
then
	ssh rhce
fi


# End of script
