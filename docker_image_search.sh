#!/usr/local/bin/bash

## Author       :   Harsha Vardhan J
## License      :   MIT
##
## Description  :   This script downloads the link given by the search term and
##                  check to see how many pulls have been made against that
##                  image, how many stars the image has, and the name of the 
##                  repository returned by the search in that link.


# Function to delete created temporary file(s)
function finish
{
    for FILE in "${URL_DATA}" "${SEARCH_RESULTS}" "${FILTER_RESULTS}"
    do
        if [ -e "${FILE}" ]
        then
            cd "$( dirname "${FILE}" )" && rm -f "$( basename "${FILE}" )"
        fi
    done
}

# Trapping script exit(0), SIGHUP(1), SIGINT(2), SIGQUIT(3), SIGTRAP(5), SIGTERM(15) signals to cleanup temporary files
#trap finish 0 1 2 3 5 15
trap finish EXIT SIGHUP SIGINT SIGQUIT SIGTRAP SIGTERM


# Checking if arguments are given
if [[ $# -ne 1 ]]
then
	printf '%s' "\\n $0 : Search term not provided as argument. \\n USAGE: $0 'Search Term' \\n"
	exit 1
elif [[ $# -eq 1 ]]
then
	# Creating temporary file to store downloaded webpage
	URL_DATA=$( mktemp -p "${TMPDIR}" docker_script.XXX )
	SEARCH_RESULTS=$( mktemp -p "${TMPDIR}" docker_script.XXX )
	FILTER_RESULTS=$( mktemp -p "${TMPDIR}" docker_script.XXX )

	# Variable 'SEARCH' assigned to first argument
	SEARCH=$1

	# Link to webpage that is to be downloaded
	LINK="https://hub.docker.com/search/?isAutomated=0&isOfficial=0&page=1&pullCount=0&q=$SEARCH&starCount=0"

	# Downloading webpage using 'wget' or 'cURL' and storing in a temporary file
	wget "${LINK}" -O "${URL_DATA}" 2>/dev/null || curl "${LINK}" -o "${URL_DATA}" 2>/dev/null

	# Extracting the results information from the downloaded webpage
#	cat "${URL_DATA}" | awk -F'\"results\":' '{print $2}' | tr -d '\n' > "${SEARCH_RESULTS}"
	awk -F'\"results\":' '{print $2}' < "${URL_DATA}" | tr -d '\n' > "${SEARCH_RESULTS}"

	# Filtering the first five results from the search results
#	cat "${SEARCH_RESULTS}" | awk -F'},' '{print $1, "\n", $2, "\n", $3, "\n", $4, "\n", $5}' > "${FILTER_RESULTS}"
	( awk -F'},' '{print $1, "\n", $2, "\n", $3, "\n", $4, "\n", $5}' < "${SEARCH_RESULTS}" ) > "${FILTER_RESULTS}"

	# Calculating the number of results obtained
#	TOTAL=$( cat "${FILTER_RESULTS}" | wc -l )
	TOTAL=$( wc -l < "${FILTER_RESULTS}" )

	# Mapping the values pertaining to repo name, number of stars, and number of
	# pulls in their corresponding arrays

#	cat "${FILTER_RESULTS}" | awk -F',' '{print $1}' | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/repo_name:\(.*\)/\1/' > "${REPO_NAMES}"
#	mapfile -t REPOS < <( cat "${FILTER_RESULTS}" | awk -F',' '{print $1}' | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/repo_name:\(.*\)/\1/' | sed 's|\\u002F|/|p' )
	mapfile -t REPOS < <( ( awk -F',' '{print $1}' < "${FILTER_RESULTS}" ) | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/repo_name:\(.*\)/\1/' | sed 's|\\u002F|/|p' )

#	cat "${FILTER_RESULTS}" | awk -F',' '{print $3}' | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/star_count:\([0-9].*\)/\1/' > "${STAR_COUNT}"
#	mapfile -t STAR < <( cat "${FILTER_RESULTS}" | awk -F',' '{print $3}' | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/star_count:\([0-9].*\)/\1/' )
	mapfile -t STAR < <( ( awk -F',' '{print $3}' < "${FILTER_RESULTS}" ) | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/star_count:\([0-9].*\)/\1/' )

#	cat "${FILTER_RESULTS}" | awk -F',' '{print $4}' | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/pull_count:\([0-9].*\)/\1/' > "${PULL_COUNT}"
	mapfile -t PULL < <( ( awk -F',' '{print $4}' < "${FILTER_RESULTS}" ) | tr -d '[' | tr -d '{' | tr -d '"' | tr -d ' ' | sed 's/pull_count:\([0-9].*\)/\1/' )
	
	# Formatting output of script
	HEADER="\n %-40s %10s %15s\n"
	DIVIDER=" -------------------------------------------------------------------"
	FORMAT=" %-40s %10s %15s\n"
	printf "$HEADER" "REPO" "STARS" "PULLS"
	printf "$DIVIDER \n"

	# Printing the results stored in each array, element by element.
	for (( VALUES=1 ; VALUES<=TOTAL ; VALUES++ )); do
		printf "$FORMAT" "${REPOS[${VALUES}-1]}" "${STAR[${VALUES}-1]}" "${PULL[${VALUES}-1]}"
	done
fi

######################################### End of script ###########################################
