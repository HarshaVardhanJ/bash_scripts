#!/usr/bin/env bash
#
#: Title        : check_image_file.sh
#: Date         :	21-Feb-2019
#: Author       :	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      : 0.1 (Stable)
#: Description  : Checks the image file/compressed file that is to
#                 be written to the external disk. Requires the path 
#                 to the file as an argument.
#                
#: Options      : Requires one argument, namely the full/relative path
#                 to the image file. Do not quote the argument. If there
#                 are any spaces in the file/directory names, escape them
#                 with a backslash.
#: Usage        :	Call the script with the image file as an argument
#                     ./check_image_file.sh /path/to/image/file
#                     ./check_image_file.sh ../relative/path/to/image/file
################

# Exit when a command fails and returns a non-zero exit code
set -e


# (WORKS)
#
# Function that outputs the type of the file given as
# input. Requires one argument, which is the absolute
# or relative path to the file whose type is to be
# checked.
#
# Usage  : check_image_file__file_signature_check_method "/path/to/file"
# Output : The file's type and signature is returned.
function check_image_file__file_signature_check_method() {
  
  # Array that stores name of command that
  # is used to check the file type.
  # The reason an array is used is arrays are 
  # useful in keeping parameters/flags whole
  local -a signatureCheckCommand
  
  # `file` command with the appropriate flags
  #
  # Command : file -b -L
  #           -b --> Filename not prepended(brief output)
  #           -L --> follow symlinks(dereference)
  signatureCheckCommand=(file -b -L)

  # If number of argument = 1
  if [[ $# -eq 1 ]] ; then
    # Expand the array containing the command and its flags
    # file -b -L /path/to/file
    "${signatureCheckCommand[@]}" "$1"
  else
    print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s \
    "Expecting one file as argument. Use either relative or absolute path." \
    && exit 1
  fi

}


# (WORKS)
#
# Function that checks the input to validate the file and check
# if it matches any of the allowed signatures (iso,zip,etc).
# If the file matches, the absolute path to the file is returned
# as output.
#
# Usage  : check_image_file__file_signature_match_check "/path/to/file"
# Output : /absolute/path/to/file
function check_image_file__file_signature_match_check() {

  # File signatures to match
  # The file signatures are generated by running
  #   `file /path/to/file`
  local -a fileSignatureArray
  
  # File signature of the input file
  local fileSignature

  # Signatures listed are (in order) = ("ISO file" "Zip file" "tar.gz file" "bzip2 file")
  fileSignatureArray=("DOS/MBR boot sector" "Zip archive data" \
                "POSIX tar archive" "bzip2 compressed data")

  # If number of arguments = 1
  if [[ $# -eq 1 ]] ; then
    # If the argument is a file which is non-zero size, and is readable by the
    # user running the script
    if [[ -s "$1" && -r "$1" ]] ; then

      # Calling function to get the file's signature and setting the result to \
      # the fileSignature variable
      fileSignature="$(check_image_file__file_signature_check_method "$1" 2>/dev/null)"

      # If the 'fileSignature' variable has been set
      if [[ -v fileSignature ]] ; then
        # For a list of all signatures in the 'fileSignatureArray' array
        for SIGNATURE in "${fileSignatureArray[@]}" ; do
          # If the fileSignature value matches any of the permitted signatures \
          # in the array
          if [[ "${fileSignature}" =~ ${SIGNATURE} ]] ; then
            # Print resolved symlinks or canonicalised file names, \
            # as per 'readlink' manpage
            readlink -f "$1" \
              && break
          fi
        done
        # Print an error if none of the signatures match
       # print_err -e 1 -s "The file \"$1\" does not match any of the permitted signatures. \
       #   Its signature is \"$(check_image_file__file_signature_check_method "$1")\"."
      fi

    # If the file doesn't exist, or is of size zero, or is unreadable by the user which
    # the script is running as
    else
      print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s \
      "File \"$1\" either does not exist, is of zero-size, or is unreadable by the user \"${USER}\"."
    fi  
  # If number of arguments is not equal to 1
  else
    print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s \
    "$# arguments have been provided. Requires only 1."
  fi

}


# Main function that should be called
function check_image_file__main() {
  # Local array for storing paths to files that \
  # need to be imported
  local -a importFiles
  importFiles=( "/Users/harshavardhanj/GitRepos/bash_scripts/usb_flash/general_functions.sh" )

  # Import the 'general_functions.sh' file first
  source "/Users/harshavardhanj/GitRepos/bash_scripts/usb_flash/general_functions.sh"

  # Calling the 'import_files' function which helps import scripts and prevent recursive \
  # importing
  import_files "${importFiles[@]}"
}

# Calling the main function
check_image_file__main

# This file isn't meant to be executed. It is preferable to unset the 'execute' bit on this file.
# To solve the issue of circular dependencies, it is better to unset the execute bit on all scripts \
# that do not absolutely need it. This way, when a certain file is  imported/sourced, the commands \
# in it aren't executed. Ideally, only the file/script that is responsible for handling user input \
# would have the execute bit set.

# End of script