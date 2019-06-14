#!/usr/bin/env bash
#
#: Title        :
#: Date         :	$(date +%d-%b-%Y)
#: Author       :	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :
#: Description  :
#                
#                
#                
#                
#: Options      :
#: Usage		:	
################



source ./general_functions.sh

function importFunc() {
	# Local array
	local -a importFiles
	importFiles=( "./general_functions.sh" \
						"./var_file_collection.sh" \
						"./commands_check.sh" \
						"./os_check.sh" )
	# Importing the 'general_functions.sh' file. Contains \
	# helper functions
	source ./general_functions.sh

	# Calling the 'import_files' function which is defined \
	# in the 'general_functions.sh' file
	import_files "${importFiles[@]}"
}

# Calling the 'importFunc' function
importFunc \
	&& print_err -f "${FUNCNAME[@]}" -l "${LINENO}" -e 0 -s "Done importing all necessary functions"

# If the OS is supported
if [[ "$(os_check)" = "Mac" ]] ; then
	# Declaring global variables
	declare -gix testVar__testFile
	declare -gx testFile1__testFile
	# Assigning values to declared variables
	testVar__testFile=1
	testFile1__testFile="/Users/harshavardhanj/Desktop/testfile1"
	testFile2__testFile="/Users/harshavardhanj/Desktop/testfile2"

	# Passing the declared global variables to the 'vars_files_array' submodule of the \
	# 'vars_files_array' function
	var_file_collection__vars_files_array testVar__testFile testFile1__testFile testFile2__testFile
# If the OS is not supported
else
	print_err -f "${FUNCNAME[@]}" -l "${LINENO}" -e 1 -s "Unsupported OS"
fi

print_err -e 0 -s "Printing all arrays"
var_file_collection__vars_files_array getall

print_err -e 0 -s "Deleting all arrays"
var_file_collection__vars_files_array delall

print_err -e 0 -s "Cleanup"
var_file_collection__vars_files_array cleanup
