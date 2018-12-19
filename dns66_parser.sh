#!/usr/bin/env bash
#
#: Title        :   dns66_parser.sh
#: Date         :   19-Dec-2018
#: Author       :   "Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :   1.0 (Stable)
#: Description  :   This script accepts a JSON file as an argument.
#                   It parses the JSON file and extracts links and
#                   names from it. Then, it fetches files that the
#                   links point to and searches through those files
#                   to check if any of the given search terms are
#                   found.
#
#: Options      :   Requires filename that contains JSON to be parsed,
#                   as an argument.
#: Usage        :   Run the script with the filename as an argument
#                           ./dns66_parser.sh ~/Downloads/file.txt
################


# Calling the 'finish' function when script is terminated or exits
trap finish EXIT SIGHUP SIGINT SIGTERM


# Function to cleanup after script exit
function finish() {

	# During some of the runs, the temp directory is not deleted
	# This is because up to 20 'wget' commands are being forked to the
	# background. Once the 'for loop' is done forking all the 'wget'
	# commands to the background, the script exits and the 'finish()'
	# function is run, which deletes the temp folder and files. Since
	# some of the 'wget' commands are still running in the background,
	# the files will be downloaded to the now non-existent temp directory.
	# This creates the temp directory and adds the downloaded files. This
	# causes the directory and few of the files to exist and not be deleted.
	#################### Fix implemented.
	# Added a 'wait' command after the 'for' loop. This makes the script wait
	# for all background processes to finish before proceeding.

	# If temporary directory exists
	if [[ -d "${TEMP_DIR}" ]]
	then
		# Deleting temporary directory
		rm -r "${TEMP_DIR}"
	fi

	# Unsetting all global variables
	for VARIABLE in A_ARRAY OUTPUT_FILE DOWNLOAD_LOGFILE TEMP_DIR
	do
		unset -v "${VARIABLE}"
	done

}


# File to which filtered output can be written
OUTPUT_FILE="/Users/harshavardhanj/Desktop/dns66_parser_output.txt"

# File to which log data can be written
DOWNLOAD_LOGFILE="/Users/harshavardhanj/Desktop/wget_logfile.log"

# Function that filters the JSON file to extract data as per the given regex
function filter_json() {
	# Regexes defined
	local URL_REGEX='"location":"http[s]://.*?",'
	local STATE_REGEX='"state":[0-9]?,'
	local NAME_REGEX='"title":"[A-Za-z ]*?"'

	# If file exists and is not empty
	if [[ -s "$1" ]]
	then
		# Assign argument to read-only variable, FILE
		local -r FILE="$1"

		# Check if OS is Linux or MacOS and use the appropriate version of 'grep'
		# Format text in JSON file to the format
		#	"Link"="Name"
		if [[ $(uname -a) =~ "Darwin" ]]
		then
			# Filter command explained : 
			# obtain only matches as per the regex | remove characters related to JSON and separate with newline | print links and name separated by '=' \
			# | remove '"location":' | remove '"title":' | replace ' = ' with '=' | output to stdout and the file defined in OUTPUT_FILE variable
			# Formats as "LINK"="NAME"
			grep -Eo "${URL_REGEX}""${STATE_REGEX}""${NAME_REGEX}" "${FILE}" | sed $'s/},{/\\\n/g' | awk -F ',' '{print $1,"=",$3}' \
				| sed 's/"location"://g' | sed 's/"title"://g' | sed 's/\ =\ /=/g' | tee "${OUTPUT_FILE}"
		elif [[ $(uname -a) =~ "Linux" ]]
		then
			grep -Po "${URL_REGEX}""${STATE_REGEX}""${NAME_REGEX}" "${FILE}" | sed $'s/},{/\\\n/g' | awk -F ',' '{print $1,"=",$3}' \
				| sed 's/"location"://g' | sed 's/"title"://g' | sed 's/\ =\ /=/g' | tee "${OUTPUT_FILE}"
		fi
	# If the argument passed is not a file or is empty
	else
		printf '%s\n' "Needs JSON file(with full path) as argument."
		exit 1
	fi
}


# Function that creates an associative array and adds the links and name to it.
# The format is as follows:
#    A_ARRAY[KEY]=VALUE
#    A_ARRAY[NAME]=LINK
function create_array() {
	# Declare associative array
	declare -gA A_ARRAY

	# Backup the default IFS
	OLD_IFS=$IFS

	# Loop through names and links separated by '=' in file
	while IFS='=' read -r LINK NAME
	do
		# Add link and names to associative array
		# key   --> Name
		# value --> Link
		A_ARRAY["${NAME}"]="${LINK}" # [NAME]=LINK
	done < <(filter_json "${@}")

	# Restore old IFS
	IFS=$OLD_IFS
}


# Function that retrieves files from download links in parallel
# while spawning no more than 20 background processes for the downloads.
function retrieve_files() {
	# Creating a temporary directory
	declare -g TEMP_DIR=$(mktemp --tmpdir -d dns66.XXXX)

	# If temporary directory exists
	if [[ -d "${TEMP_DIR}" ]]
	then
		# Calling 'create_array' function and passing all arguments to it
		create_array "${@}"

		# If the associative array contains more than one element, meaning if it is non-empty
		if [[ ${#A_ARRAY[@]} -gt 1 ]]
		then
			# for loop through all the values of the array, which are the links, after removing the double quotes
			# The reason for removing the double quotes is that 'wget' throws an error if they are present
			# ${VARIABLE//string/replace} replaces all occurences of 'string' with 'replace' after expanding VARIABLE
			# Same applies to arrays. ${ARRAY[@]//\"/} is used to remove all double quotes from the links
			for LINK in "${A_ARRAY[@]//\"/}"
			do
				# If number of background jobs is >= 30, then wait
				while [[ $( jobs -p | wc -c ) -ge 30 ]]
				do
					sleep 0.50
				done

				# Download files from links in the background and save them to the directory in the TEMP_DIR variable
				wget --timeout=20 --directory-prefix="${TEMP_DIR}" "${LINK}" >> "${DOWNLOAD_LOGFILE}" 2>&1 &
			done

			# Wait for all downloads to complete before progressing
			wait

		# If array is empty
		else
			printf '%s\n' "Array is empty. Check DNS file."
		fi
	# If temporary directory does not exist
	else
		printf '%s\n' "Temporary directory could not be created for storing DNS files. Files will not be downloaded"
	fi
}


function analyse_files() {

	# Calling the 'retrieve_files' function
	retrieve_files "${@}"

	# Creating array for storing search terms
	local -a SEARCH_TERMS

	# Search terms
	local -r SEARCH_TERMS=("github" "imgur" "duckduckgo" "youtube")

	# File to store search results
	local SEARCH_RESULTS="/Users/harshavardhanj/Desktop/search_results.log"

	# If the file defined in the SEARCH_RESULTS variable does not exist
	if [[ ! -a "${SEARCH_RESULTS}" ]]
	then
		touch "${SEARCH_RESULTS}"
	fi

	# If SEARCH_TERMS variable is set and the array's length is non-zero
	if [[ -v SEARCH_TERMS  && "${#SEARCH_TERMS[@]}" -gt 0 ]]
	then
		# Loop through all search term
		for SEARCH in "${SEARCH_TERMS[@]}"
		do
			# Print a header to indicate which search term is being used
			printf '\t%s\n%s\n%s' "-------------------" \'"${SEARCH}"\' "-------------------" >> "${SEARCH_RESULTS}"
			
			# Loop through all the retrieved files
			for FILE in $( ls "${TEMP_DIR}" )
			do
				# Print a header to indicate which file is being searched
				printf '%s\n%s\n%s' "-------------------" \'"${FILE}"\' "-------------------" >> "${SEARCH_RESULTS}"
				grep -i "${SEARCH}" "${TEMP_DIR}"/"${FILE}" >>"${SEARCH_RESULTS}"
			done
		done
	else
		exit 1
	fi
}

analyse_files "${@}"

# End of script
