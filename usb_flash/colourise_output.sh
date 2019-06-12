#!/usr/bin/env bash
#
#: Title        :   colourise_output.sh
#: Date         :   18-Aug-2018
#: Author       :   "Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :   3.0 (Stable)
#: Description  :   This script contains a function which helps colourise any string(s).
#                   The script can also direct the coloured text to standard error.
#: Options      :   Requires four arguments, at least. First one is the '--colour' option,
#                   second is the colour name, third is the '--string' option, fourth is 
#                   the string to be printed. Accepts an optional argument '--error',
#                   when given the value of '1' will print the coloured text to standard
#                   error. By default, it prints the text to standard error. Another optional
#                   argument is the '--newline' or '-n' option, which when given the value of
#                   '0' will not print a new line after the text. The default behaviour is to
#                   print a new line after every function call.
#: Usage        :   The colour of the text is to be passed as an argument
#                   to the '--colour' option. '--color' and '-c' are acceptable too. The 
#                   text to be printed is passed as an argument to the '--string' option.
#                   '-s' is acceptable too.
#                   Note that the text should be passed witin quotation marks. The colour 
#                   option can be case-insensitive too. Multiple strings with different 
#                   colours can be passed too. Also, text can be printed to standard error
#                   by setting the '--error' flag to '1'. By default, all text is printed
#                   to standard output. Finally, the default behaviour of printing a new
#                   line after every function call can be overriden by passing the value of
#                   '0' to the '--newline' or '-n' flag.
#                   Example:    ./colourise_output.sh --colour blue --string "Text in blue"
#                               ./colourise_output.sh --color BlUe --string "Text in blue"
#                               ./colourise_output.sh --colour red --string "Red text" \
#                                                     -c blue -s "Blue text"
#                               ./colourise_output.sh -c red -s "Print to stderr" -e 1
#                               ./colourise_output.sh -c red -s "Print to stderr" -n 0
################

# Function that prints some text intended to inform the user
# about the script's usage
function print_help() {
	cat <<- EOF

Usage            :          $0 --colour colour --string "Text to be coloured"
                            $0 --color color --string "Text to be coloured"
                            $0 --color color --string "Text to be coloured" -c color -s "Text to be coloured"
                            $0 --colour colour --string "Text to be coloured" --error 0
                            $0 --colour colour --string "Text to be coloured" -e 1
                            $0 --colour colour --string "Text to be coloured" -e 1 --newline 0
                            $0 --colour colour --string "Text to be coloured" -n 1

Colours Accepted :          blue, cyan, green, orange, purple, red, violet, white, yellow

Error Flag       :          Can be set to 1 if the text is to be printed to standard error.
                            By default, text will be printed to standard output.
                            Accepts only 1 and 0 as values. The value 0 is the default value.
                            '--error 1' or '-e 1' will print the text to standard error.

Newline Flag     :          Can be set to 0 if no newline is to be printed at the end. By default,
                            newlines are printed after every function call so that the text printed
														by the next function call isn't on the same line. This can be overriden
														if needed by passing '--newline 0' or '-n 0'.

Note             :          All strings will be printed followed by a space. You do not need to add 
                            spaces between multiple strings. The strings should not be empty.

                            The script accepts '--colour', '--color', and '-c' as flags for the colour(s)
                            The script accepts '--string' and '-s' as flags for the string(s)
                            The script accepts '--error' and '-e' as flags for printing to standard error
                            The script accepts '--newline' and '-n' as flags for controlling newline printing
														behaviour.

EOF
}

# Function containing all colour definitions(codes) and which prints the coloured text
function colourise() {

	# Colour definitions
	if tput setaf 1 &> /dev/null; then
		tput sgr0; # reset colors
		local -r BOLD=$(tput bold);
		local -r RESET=$(tput sgr0);
		# Solarized colors, taken from http://git.io/solarized-colors.
		local -r BLACK=$(tput setaf 0);
		local -r BLUE=$(tput setaf 33);
		local -r CYAN=$(tput setaf 37);
		local -r GREEN=$(tput setaf 64);
		local -r ORANGE=$(tput setaf 166);
		local -r PURPLE=$(tput setaf 125);
		local -r RED=$(tput setaf 124);
		local -r VIOLET=$(tput setaf 61);
		local -r WHITE=$(tput setaf 15);
		local -r YELLOW=$(tput setaf 136);
	else
		local -r BOLD='';
		local -r RESET=$'\e[0m'
		local -r BLUE=$'\e[1;34m'
		local -r CYAN=$'\e[1;36m'
		local -r GREEN=$'\e[1;32m'
		local -r ORANGE=$'\e[1;33m'
		local -r PURPLE=$'\e[1;35m'
		local -r RED=$'\e[1;31m'
		local -r VIOLET=$'\e[1;35m'
		local -r WHITE=$'\e[1;37m'
		local -r YELLOW=$'\e[1;33m'
	fi

	# Set case-insensitive matching in 'bash'
	# This is to help match the given colour in a case-insensitive fashion
	shopt -qs nocasematch

	# Implementation of adding multiple colour codes with multiple strings
	# If an even number of arguments are provided and is greater than 4
	if [[ $(( $# % 2 )) -eq 0  && $# -ge 4 ]] ; then
		# Declaring local arrays for storing colours and strings
		local -a ColourVar
		local -a StringVar
		# Declaring local integer for storing value of ErrorVar flag
		local -i ErrorVar
		# Declaring local integer for storing value of NewlineVar flag
		local -i NewlineVar

		# While the number of arguments is > 0
		while [[ $# -gt 0 ]] ; do
			case "$1" in
				# If "first" argument is either '--colour', '--color', or '-c'
				--colour|--color|-c)
					# If the second argument contains one of the colours defined,
					# add the accompanying argument to variable $COLOUR
					if [[ "$2" =~ ^(blue|cyan|green|orange|purple|red|violet|white|yellow)$ ]] ; then
						ColourVar+=("${2^^}")	# Add colour to $ColourVar array and change colour name to uppercase
						shift 2             	# Shift the first two arguments away : "--colour red" have been shifted away
					# If the second argument does not contain any of the defined colours
					else
						colourise -c red -s "${FUNCNAME}" -c yellow -s "${LINENO}" -c white -s \
							"Incorrect colour option" -e 1
						print_help \
							&& return 1
					fi
				;;
				# If the "first" argument is either '--string', or '-s'
				--string|-s)
					# If the string in the second argument is not empty
					if [[ -n "$2" ]] ; then
						StringVar+=("$2")	# Add string to $StringVar array
						shift 2          	# Shift two arguments away: "--string "example"" have been shifted away
					# If the string provided is empty, print help text and exit
					else
						colourise -c red -s "${FUNCNAME}" -c yellow -s "${LINENO}" -c white -s \
							"Empty string provided. Check help text below" -e 1
						print_help \
							&& return 1
					fi
				;;
				# If the error flag is set to 1, that is if the output is to be printed to stderr
				--error|-e)
					# if the argument is either 1 or 0
					if [[ $2 =~ ^[0-1]$ ]] ; then
						ErrorVar=$2		# Assign the integer to the ErrorVar variable
						shift 2 		# Shift two arguments away "--error 1" have been shifted away
					# If the argument does not match either '1' or '0', print help test and exit
					else
						colourise -c red -s "${FUNCNAME}" -c yellow -s "${LINENO}"-c white -s \
							"Incorrect value provided for '-e' flag. Check help text below" -e 1
						print_help \
							&& return 1
					fi
				;;
				# If the newline flag is set to 1, that is if a newline is to be printed at the end
				--newline|-n)
					# If the argument is either 1 or 0
					if [[ $2 =~ ^[0-1]$ ]] ; then
						NewlineVar=$2		# Assign the integer to the NewlineVar variable
						shift 2 		# Shift two arguments away "--newline 1" have been shifted away
					# If the argument does not match either '1' or '0', print help test and exit
					else
						colourise -c red -s "${FUNCNAME}" -c yellow -s "${LINENO}"-c white -s \
							"Incorrect value provided for '-e' flag. Check help text below" -e 1
						print_help \
							&& return 1
					fi
				;;
				# If any other argument is provided, then print help text and exit
				*)
					print_help \
						&& return 1
				;;
			esac
		done

		# Print the colourised text
		# Cycle through all indices of the $ColourVar and $StringVar
		# arrays.
		#
		# seq 0 1 3 = 0 1 2 3
		# ${#StringVar[@]} = Number of elements in $StringVar array(which is equal to half of number of arguments)
		# which is equal to total number of times a string should be printed.
		# For each coloured string, there are two arguments provided.
		#
		# 1 is being subtracted from ${#StringVar[@]} because arrays in bash are indexed from 0 onwards.
		# So, if the array has 5 elements, the value of ARGS needs to range from 0 to 4, hence the subtraction.
		case $ErrorVar in
			# If the ERROR variable is set to 1, print the colourised text to stderr
			1)
				for ARGS in $( seq 0 1 $(( ${#StringVar[@]} - 1 )) ) ; do
					printf '%s ' "${!ColourVar["${ARGS}"]}" "${StringVar["${ARGS}"]}" >&2
				done
			;;
			# If the ERROR variable is set to 0, print the colourised text to stdout (default behaviour)
			0|*)
				for ARGS in $( seq 0 1 $(( ${#StringVar[@]} - 1 )) ) ; do
					printf '%s ' "${!ColourVar["${ARGS}"]}" "${StringVar["${ARGS}"]}"
				done
			;;
		esac

		# Reset any colour modifications done previously. This is done to prevent the \
		# colouring of any text not printed by this function.
		# Also, print a new line after all the text has been printed. If this is not \
		# done, further usage of this function will print all text on the same line as \
		# the previous function call
		case $NewlineVar in
			# If the NewlineVar is set to 0, don't print a newline
			0) printf '%s' "${RESET}" ;;
			# If the NewlineVar is set to 1, print a newline(default behaviour)
			1|*) printf '%s\n' "${RESET}" ;;
		esac

	# If number of arguments is not even and are not greater than 4, print help text and exit
	else
		colourise -c red -s "${FUNCNAME}" -c yellow -s "${LINENO}" -c white -s \
			"Number of arguments provided = $#" -e 1
		colourise -c red -s "${FUNCNAME}" -c yellow -s "${LINENO}" -c white -s \
			"Number of arguments required = 4(atleast)" -e 1
		print_help \
		 && return 1
	fi

	# Unset case-insensitive matching in 'bash'
	# Case-sensitive matching is the default behaviour in 'bash'
	shopt -qu nocasematch
}

# Calling the 'colourise' function and passing all arguments to it
#colourise "$@"

# This script does not need to have the execute bit set as it will be imported by the other scripts
# that will make use of the functions within this script.

# End of script
