#!/usr/local/bin/bash

## Author       :   Harsha Vardhan J
## License      :   MIT
##
## Description  :   This script downloads the link given by the search term and
##                  check to see how many pulls have been made against that image returned by the
##                  search in that link.


# Function to delete created temporary file(s)
function finish
{
    for FILE in "${URL_DATA}" "${SEARCH_RESULTS}" "${FILTER_RESULTS}"
    do
        if [ -e "${FILE}" ]
        then
            cd $( dirname "${FILE}" ) && rm -f $( basename "${FILE}" )
        fi
    done
}

# Trapping script exit(0), SIGHUP(1), SIGINT(2), SIGQUIT(3), SIGTRAP(5), SIGTERM(15) signals to cleanup temporary files
trap finish 0 1 2 3 5 15


# Checking if arguments are given
if [ $# -ne 1 ]
then
	printf "\n$0 : Search term not provided as argument. \n USAGE: $0 'Search Term'\n"
	exit 1
elif [ $# -eq 1 ]
then
	# Creating temporary file to store downloaded webpage
	URL_DATA=$( mktemp -p "${TMPDIR}" docker_script.XXX )
	SEARCH_RESULTS=$( mktemp -p "${TMPDIR}" docker_script.XXX )
	FILTER_RESULTS=$( mktemp -p "${TMPDIR}" docker_script.XXX )
#
	# Variable 'SEARCH' assigned to first argument
	SEARCH=$1
#
	# Link to webpage that is to be downloaded
	LINK="https://hub.docker.com/search/?isAutomated=0&isOfficial=0&page=1&pullCount=0&q=$SEARCH&starCount=0"
#
	# Downloading webpage and storing in temporary file
#	wget "${LINK}" -O "${URL_DATA}" 2>/dev/null
	curl "${LINK}" -o "${URL_DATA}" 2>/dev/null
#

	cat "${URL_DATA}" | awk -F'\"results\":' '{print $2}' | tr -d '\n' > "${SEARCH_RESULTS}"
#
	cat "${SEARCH_RESULTS}" | awk -F'},' '{print $1, "\n", $2, "\n", $3, "\n", $4, "\n", $5}' > "${FILTER_RESULTS}"

#	cat "${FILTER_RESULTS}" | awk -F',' '{print $1}' | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/repo_name:\(.*\)/\1/' > "${REPO_NAMES}"
	mapfile -t REPOS < <( cat "${FILTER_RESULTS}" | awk -F',' '{print $1}' | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/repo_name:\(.*\)/\1/' )

#	cat "${FILTER_RESULTS}" | awk -F',' '{print $3}' | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/star_count:\([0-9].*\)/\1/' > "${STAR_COUNT}"
	mapfile -t STAR < <( cat "${FILTER_RESULTS}" | awk -F',' '{print $3}' | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/star_count:\([0-9].*\)/\1/' )

#	cat "${FILTER_RESULTS}" | awk -F',' '{print $4}' | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/pull_count:\([0-9].*\)/\1/' > "${PULL_COUNT}"
	mapfile -t PULL < <( cat "${FILTER_RESULTS}" | awk -F',' '{print $4}' | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/pull_count:\([0-9].*\)/\1/' )
	
	HEADER="\n %-45s %10s %15s\n"
	DIVIDER=" ------------------------------------------------------------------------"
	FORMAT=" %-45s %10s %15s\n"
	WIDTH=45
	printf "$HEADER" "REPO" "STARS" "PULLS"
	printf "$DIVIDER\n"

	for VALUES in {0..5..1}; do
		printf "$FORMAT" "${REPOS[$VALUES-1]}" "${STAR[$VALUES-1]}" "${PULL[$VALUES-1]}"
	done
#	printf "$FORMAT" "${REPOS[0]}" "${STAR[0]}" "${PULL[0]}"
#	printf "$FORMAT" "${REPOS[1]}" "${STAR[1]}" "${PULL[1]}"
#	printf "$FORMAT" "${REPOS[2]}" "${STAR[2]}" "${PULL[2]}"
#	printf "$FORMAT" "${REPOS[3]}" "${STAR[3]}" "${PULL[3]}"
#	printf "$FORMAT" "${REPOS[4]}" "${STAR[4]}" "${PULL[4]}"


#	cat "${FILTER_RESULTS}"
	# Filtering required information i.e. "pull_count" from the downloaded webpage
	#PULLS="$(cat "${TEMP_FILE}" | awk '/\,\"pull_count\":[0-9]*.\,/' | awk -F',"pull_count":' '{print $2}' | awk -F',' '{print $1}')"
#
	# Displaying number of pulls
	#printf "\nNumber of pulls = "${PULLS}"\n"
fi


######################################### End of script ###########################################
