#!/bin/bash
## Author		:	Harsha Vardhan J
## License		:	MIT
##
## Description	:	This script tries to display the network activity of a process that matches the search term or PID
##					which is given as an argument. It uses 'nettop' to display the statistics. By default, only traffic
##					on the wireless interface will be shown.
#
# If no argument is provided
if [ $# -ne 1 ]
then
	printf "$0 : Process name or PID not provided as argument. \n USAGE: $0 process_name\nUSAGE: $0 PID"
	exit 1
elif [ $# -eq 1 ]
then
	PNAME=$1
	SEARCH_RESULT=$(ps aux | grep "${PNAME}" | grep -v "grep" | grep -v $0)
	SEARCH_STATUS=$?
fi

if [ "${SEARCH_STATUS}" -ne 0 ]
then
	printf "\nPlease enter a different PID or search term. Could not find any processes that match the search term or PID.\n"
elif [ "${SEARCH_STATUS}" -eq 0 ]
then
	if [ $(printf "${SEARCH_RESULT}" | awk '{print $1}') == 'root' ]
	then
		printf "\n\t\t\tThe process you've searched for is running as 'root'.\n \
			You will need administrator privileges to view the network activity of that process.\n \
			You might want to consider running this script as root. It is not advisable, though.\n"
		printf "\nHere's the summary of that process :\n"
		ps aux | head -1 | awk '{printf("%s \t %s \t %s \t %s \t %s \t\t %s \t %s \t %s \t %s \t %s \t\t %s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)}'
		echo ""${SEARCH_RESULT}"" | awk '{printf("%s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)}'

		printf "\n"
		read -p "Do you wish to run the network monitor as root? (y -- yes ; n -- no) : " PROMPT

		if [ "${PROMPT}" == 'y' ] || [ "${PROMPT}" == 'Y' ]
		then
			printf "\nDisplaying process network activity. Press 'q' to exit after viewing the activity." 
			printf "You will have to enter the administrator password next.\n" ; sleep 2
			sudo nettop -t external -p $(printf "${SEARCH_RESULT}" | awk '{print $2}')
		else
			printf "\nExiting script."
		fi
	else
		printf "\nDisplaying process network activity. Press 'q' to exit after viewing the activity." ; sleep 3
		nettop -m tcp -t wifi -p $(echo "${SEARCH_RESULT}" | awk '{print $2}')
	fi
fi
