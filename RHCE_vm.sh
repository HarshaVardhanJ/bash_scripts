#!/usr/bin/env bash
#
#: Title        :	RHCE_vm.sh
#: Date         :	14-Sep-2018
#: Author       :	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :	1.0
#: Description  :	This script first starts the VM tagged as "RHCE",
#              		then it pings the VM to check if it is up, then
#                	it tries to SSH into the VM until it gains access.
#: Options      :	None
#: Usage		:	Call the script. No arguments needed.
#					Example: ./RHCE_vm.sh
################



function ping_vm() {
	local -r IP="192.168.1.60"

	until ping -c3 "${IP}"
	do
		sleep 2.5
	done
}

function start_vm() {
	local -r UUID="80fc2908-3ee6-4196-85d3-b7f484e883dc"

	if [[ $( VBoxManage list runningvms ) =~ "${UUID}" ]]
	then
		printf "\n%s" "VM is running"
	else
		VBoxManage startvm --type headless "${UUID}"
	fi
}

function ssh_vm() {
	if start_vm && ping_vm
	then
		while [[ "$( ssh rhce )" =~ "System is booting up" ]]
		do
			sleep 2.5
		done
		ssh rhce
	fi
}

ssh_vm
