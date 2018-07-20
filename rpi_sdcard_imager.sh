#!/bin/bash

# Creating temporary directory and file. TEMP variable's value is the path to the temporary file
TEMP=$( mktemp -p "${TMPDIR}" rpi.XXX ) #|| TEMP=$( mktemp rpi&& )
COMP1=$( mktemp -p "${TMPDIR}" rpi.XXX ) #|| COMP1=$( mktemp rpi&& )
COMP2=$( mktemp -p "${TMPDIR}" rpi.XXX ) #|| COMP2=$( mktemp rpi&& )
MOUNT1=$( mktemp -p "${TMPDIR}" rpi.XXX ) #|| MOUNT1=$( mktemp rpi&& )
MOUNT2=$( mktemp -p "${TMPDIR}" rpi.XXX ) #|| MOUNT2=$( mktemp rpi&& )

# Function to delete the created temporary file and other files
function finish
{
    for FILE in "${TEMP}" "${COMP1}" "${COMP2}" "${MOUNT1}" "${MOUNT2}" "${HOME}"/RPi_files
    do
        if [ -e "${FILE}" ]
        then
            cd "$( dirname "${FILE}" )" && rm -rv "$( basename "${FILE}" )"
        fi
    done
}


# Trapping script EXIT(0), SIGHUP(1), SIGINT(2), SIGQUIT(3), SIGTRAP(5), SIGTERM(15) signals to cleanup temporary files
#trap finish 0 1 2 3 5 15
trap finish EXIT SIGHUP SIGINT SIGQUIT SIGTRAP SIGTERM

FLAG=0
IFS=$'\n\t'         # Setting the internal field separator to newline and tab.
cd "${HOME}" || exit

DATE="$( date "+%Y-%m-%d@%H:%M:%S" )"
BACKUP_FILE='Backup('"${DATE}"').zip'

# Variables to store results of default keystrokes
OK=0
YES=0
CANCEL=1
NO=1
ESC=255


# Functions to display different dialog boxes

function display_result()   # Displaying a box with some result and <OK> button
{       
    dialog --no-collapse --clear --backtitle "Raspberry Pi Image Burner V0.1_alpha" --title "$1" --msgbox "${RESULT}" 10 60
}

function display_message()  # Displaying a box with a message and an <OK> button
{       
    dialog --no-collapse --clear --backtitle "Raspberry Pi Image Burner V0.1_alpha" --title "$1" --msgbox "$2" 10 60
}

function display_info()     # Displaying a box without any buttons that remains on screen for a given time interval
{
    dialog --no-collapse --backtitle "Raspberry Pi Image Burner V0.1_alpha" --infobox "$1" 10 60 ; sleep "$2"
}

function display_yesno()    # Displaying a box with <YES> and <NO> buttons and a prompt
{
    dialog --no-collapse --clear --backtitle "Raspberry Pi Image Burner V0.1_alpha" --yesno "$1" 10 60
}

function display_gauge()    # Displaying a box with a gauge to show progress
{
    dialog --no-collapse --clear --backtitle "Raspberry Pi Image Burner V0.1_alpha" --gauge "$1" 10 60
}


# Flag value at this point = 0
# First while loop. Flag codes : [+/-]1[1-10][0,1]
# Obtaining search term from user to find image file
while [[ "${FLAG}" -ge 0  && "${FLAG}" -ne 110 ]]
do
    dialog --backtitle "Raspberry Pi Image Burner V0.1_alpha" --title "File to be written to SD Card" --clear \
        --inputbox "Enter term to search for compressed/image file" 0 0 2>"${TEMP}" 
    RESP=$?

    case $RESP in
        $OK)
            RESULT="$( <"${TEMP}" )"
            SEARCH="${RESULT}"
            display_result "Search term entered."
            FLAG=110
            ;;
        $CANCEL)
            display_message "Cancel Key Pressed."
            FLAG=-111
            ;;
        $ESC)
            display_message "Escape Key Pressed."
            FLAG=-111
            ;;
    esac
done


# Second if-statement. Flag codes : [+/-]2[1-10][0,1]
if [[ "${FLAG}" -eq 110 ]]
then
    ((i=0))     # Define working variable
    W=()        # Define working array

    # Process data line by line
    while read -r LINE
    do
        ((i= i+1))
        W+=("$i" "$LINE")
    done< <( find "${HOME}" -maxdepth 6 -type f \( \( -name \*.zip -o -name \*.bz2 -o -name \*.xz -o -name \*.gz -o -name \*.7z \) -and \
        -iname "*${SEARCH}*" \) 2>/dev/null )

    SEARCH_RESULTS=$( find "${HOME}" -maxdepth 6 -type f \( \( -name \*.zip -o -name \*.bz2 -o -name \*.xz -o -name \*.gz -o -name \*.7z \) \
        -and -iname "*${SEARCH}*" \) 2>/dev/null )

    dialog --no-collapse --clear --backtitle 'Rapberry Pi Image Burner V0.1_alpha" --title "List of .zip and .img files found matching '"${SEARCH}"'' \
        --menu "Pick the file to be burned" 0 0 0 "${W[@]}" 2>"${TEMP}"
    RESP=$?

    ############################################################ Print the selected file(name)
    case $RESP in
        $OK)
            FILE=$( printf "${SEARCH_RESULTS}" | sed -n "$(printf ""$(cat "${TEMP}")" p" | sed 's/ //')" )
            RESULT="$( printf "${FILE}" )"
            display_result 'File selected: \
            	'"${RESULT}"''
            FLAG=210
            ;;
        $CANCEL)
            display_message "Cancelled"
            FLAG=211
            ;;
        $ESC)
            display_message "Exited."
            FLAG=-211
            ;;
    esac
fi

# FLag value at this point = 210 (if successful)
# Third if-statement. Flag codes : [+/-]3[1-10][0,1]
############################################################ Extraction of '.img' file
if [[ "${FLAG}" -eq 210 ]]
then
    #FILENAME=$( basename "${FILE}" )
    if [[ "${FILE}" == *.zip || "${FILE: -4}" == ".zip" ]] # If the file picked has a '.zip' extension
    then
        mkdir "${HOME}"/RPi_files
        ( pv -n "${FILE}" | tar -xvf - -C "${HOME}"/RPi_files ) 2>&1 | display_gauge "Extracting image from zip file." && true

        if true
        then
            display_message 'Extracted image from '"${FILE}"'.'
            IMG="$( ls "${HOME}"/RPi_files/*.img )"
            FLAG=310
        else
            display_message "The extraction seems to have failed."
            FLAG=311
        fi
    elif [[ "${FILE}" == *.gz || "${FILE: -3}" == ".gz" ]] # If the file picked has a '.gz' extension
    then
        mkdir "${HOME}"/RPi_files
        ( pv -n "${FILE}" | tar -xvzf - -C "${HOME}"/RPi_files ) 2>&1 | display_gauge "Extracting image from zip file." && true

        if true
        then
            display_message 'Extracted image from '"${FILE}"'.'
            IMG="$( ls "${HOME}"/RPi_files/*.img )"
           FLAG=310
        else
            display_message "The extraction seems to have failed."
            FLAG=311
        fi
    elif [[ "${FILE}" == *.bz2 || "${FILE: -3}" == ".bz2" ]] # If the file picked has a '.bz2' extension
    then
        mkdir "${HOME}"/RPi_files
        ( pv -n "${FILE}" | tar -xjvf - -C "${HOME}"/RPi_files ) 2>&1 | display_gauge "Extracting image from bzip2 file." && true

        if true
        then
            display_message 'Extracted image from '"${FILE}"'.'
            IMG="$( ls "${HOME}"/RPi_files/*.img )"
            FLAG=310
        else
            display_message "The extraction seems to have failed."
            FLAG=311
        fi
    elif [[ "${FILE}" == *.xz || "${FILE: -3}" == ".xz" ]] # If the file picked has a '.xz' extension
    then
        mkdir "${HOME}"/RPi_files
        ( pv -n "${FILE}" | tar -xvJf - -C "${HOME}"/RPi_files ) 2>&1 | display_gauge "Extracting image from zip file." && true

        if true
        then
            display_message 'Extracted image from '"${FILE}"'.'
            IMG="$( ls "${HOME}"/RPi_files/*.img )"
            FLAG=310
        else
            display_message "The extraction seems to have failed."
            FLAG=311
        fi
    elif [[ "${FILE}" == *.7z || "${FILE: -3}" == ".7z" ]] # If the file picked has a '.7z' extension
    then
        mkdir "${HOME}"/RPi_files
        ( 7z e "${FILE}" -o"${HOME}"/RPi_files ) 2>&1 | display_gauge "Extracting image from zip file." && true

        if true
        then
            display_message 'Extracted image from '"${FILE}"'.'
            IMG="$( ls "${HOME}"/RPi_files/*.img )"
            FLAG=310
        else
            display_message "The extraction seems to have failed."
            FLAG=311
        fi
    elif [[ "${FILE}" == *.img || "${FILE: -4}" == ".img" ]] # If the file picked has a '.img' extension
    then
        cp "${FILE}" "${HOME}"/RPi_files/
        IMG="$( ls "${HOME}"/RPi_files/*.img )"
#       IMG_NAME="$( basename "${IMG}" )"
        FLAG=310
    fi
fi


if [[ "${FLAG}" -eq 311 ]]
then
    display_info "Exiting script due to the failure of image extraction.\
        Please check the file selected and run the script again." 3
fi


# Flag codes : [+/-]4[1-10][0,1] 
############################################################ '.img' file extraction complete
while [[ "${FLAG}" -gt 0 && "${FLAG}" -ne 311 ]]
do
    # Flag codes : [+/-]42[0,1]
    ############################################################ USB drive selection (part-1)
    while [[ "${FLAG}" -gt 0 && "${FLAG}" -ne 420 ]]
    do
        display_message "If the pen-drive is attached to the computer, please remove it. Select <OK> when done."
        RESP=$?
    
        # Flag codes : [+/-]42[0,1]
        case $RESP in
            $OK)
                diskutil list > "${COMP1}"
                mount > "${MOUNT1}"
                FLAG=420
                ;;
            $CANCEL)
                display_message "Cancelled. Select <OK>."
                display_yesno "Exit Program?"
                RESPONSE=$?

                # Flag codes : [+/-]42[0,1]
                case $RESPONSE in
                    $YES)
                        FLAG=-421
                        display_message "Program ended. Select <OK> to close."
                        ;;
                    $NO)
                        FLAG=421
                        ;;
                    $ESC)
                        display_message "Program stopped. Select <OK> to close."
                        FLAG=-421
                        ;;
                esac
                ;;
            $ESC)
                display_message "Stopped. Select <OK>."
                display_yesno "Exit program?"
                RESPONSE=$?

                # Flag codes : [+/-]42[0,1]
                case $RESPONSE in
                    $YES)
                        FLAG=-421
                        display_message "Program stopped. Select <OK> to close."
                        ;;
                    $NO)
                        FLAG=421
                        ;;
                    $ESC)
                        FLAG=-421
                        display_message "Program stopped. Select <OK> to close."
                        ;;
                esac
                ;;
        esac
    done


    if [[ "${FLAG}" -eq 420 ]]
    then
        # Flag value at this point = 420 (on success)
        # Flag codes : [+/-]43[0,1]
        ############################################################ USB drive selection (part-2)
        while [[ "${FLAG}" -gt 0 && "${FLAG}" -ne 430 ]]
        do
            display_message "Insert the pen-drive/SD card that is to be written to. Select <OK> when done."
            RESPONSE=$?

            # Flag codes : [+/-]43[0,1]
            case $RESPONSE in
                $OK)
                    display_info "Recognising inserted pen-drive/SD card. Please wait." 4
                    diskutil list > "${COMP2}"
                    mount > "${MOUNT2}"
                    FLAG=430
                    ;;
                $CANCEL)
                    display_message "Exit program?"
                    RESPONSE=$?

                    # Flag codes : [+/-]43[0,1]
                    case $RESPONSE in
                        $YES)
                            FLAG=-431
                            display_message "Program stopped. Select <OK> to close."
                            ;;
                        $NO)
                            FLAG=431
                            display_info "Going back to drive selection" 3
                            ;;
                        $ESC)
                            FLAG=-431
                            display_message "Program stopped. Select <OK> to close."
                            ;;
                    esac
                    ;;
                $ESC)
                    display_message "Stopped. Select <OK>."
                    display_yesno "Exit program?"
                    RESPONSE=$?

                    # Flag codes : [+/-]43[0,1]
                    case $RESPONSE in
                        $YES)
                            FLAG=-431
                            display_message "Program ended. Select <OK> to close."
                            ;;
                        $NO)
                            FLAG=431
                            display_info "Going back to drive selection" 3
                            ;;
                        $ESC)
                            FLAG=-431
                            display_message "Program stopped. Select <OK> to close."
                            ;;
                    esac
                    ;;
            esac

        done
    fi


    if [[ "${FLAG}" -eq 430 ]]
    then
        # Flag value at this point = 430 (on success)
        # Flag codes : [+/-]44[0,1]
        ############################################################ Formatting and/or backing up USB drive
        while [[ "${FLAG}" -gt 0 && "${FLAG}" -ne 440 ]]
        do
            DRIVE="$( diff "${COMP1}" "${COMP2}" | grep -i '/dev/' | cut -d" " -f2 )"                                   # /dev/disk2 type
            MOUNT_DISK="$( diff "${MOUNT1}" "${MOUNT2}" | grep -i '/dev/disk' | cut -d" " -f2 )"                        # /dev/disk2s1 type
            MOUNT_DRIVE="$( diff "${MOUNT1}" "${MOUNT2}" | grep -i '/dev/disk' | cut -d" " -f4 | sed 's/\ /\\\ /g')"    # /Volumes/DRIVE type

            display_info 'The drive selected is '"${DRIVE}"' and it is mounted at '"${MOUNT_DRIVE}"'.' 3
            display_info 'The drive '"${DRIVE}"' mounted at '"${MOUNT_DRIVE}"' will be formatted to FAT32 with the name 'DRIVE'.' 3
            display_yesno 'WARNING! The drive '"${DRIVE}"' will be erased completely. To proceed, select <YES>. To halt, select <NO>.'
            RESPONSE=$?

            case $RESPONSE in
                $YES)
                    display_info 'Erasing and formatting disk '"${DRIVE}"'.' 3
                    diskutil eraseDisk FAT32 DRIVE "${DRIVE}" 
                    display_info 'Disk '"${DRIVE}"' has been erased and formatted to FAT32 with the name "DRIVE".' 3
                    display_info "The disk will now be unmounted." 3
                    diskutil unmountDisk "${DRIVE}"
                    FLAG=440
                    ;;
                $NO)
                    display_yesno "Halted disk formatting. Do you want to backup contents of the storage drive to this computer?."
                    RESPONSE=$?

                    case $RESPONSE in
                        $YES)
                            display_info 'The drive '"${MOUNT_DRIVE}"' will be renamed to "DRIVE". No loss of data will occur. This is to help make the backup.' 4
                            diskutil rename "${MOUNT_DISK}" DRIVE
                            display_info 'Backing up the contents of the drive '"${DRIVE}"' to '"${HOME}"' under the filename '"${BACKUP_FILE}"'. \
                                Depending upon the size and number of files, this may take a while. Please wait.' 5

                            display_yesno 'Do you wish to compress the backup of the contents of '"${DRIVE}"'? /
                            (Compression is CPU intensive and can take a while longer)'
                            RESPONSE=$?

                            case $RESPONSE in
                                $YES)
                                    tar -cpzf - /Volumes/DRIVE | ( pv -n > "${HOME}""/""\"${BACKUP_FILE}\".gz" ) 2>&1 | display_gauge 'Backup up contents of '"${DRIVE}"'.'
                                    ;;
                                $NO)
                                    tar -cpf - /Volumes/DRIVE | ( pv -n > "${HOME}"/"${BACKUP_FILE}" ) 2>&1 | display_gauge 'Backing up contents of '"${DRIVE}"'.'
                                    ;;
                                $ESC)
                                    display_message "Program stopped. Select <OK> to close."
                                    FLAG=-441
                                    ;;
                            esac

                            if [[ -e "${HOME}""/""\"${DRIVE_BACKUP}\".gz" || -e "${HOME}"/"${DRIVE_BACKUP}" ]]
                            then
                                display_info 'The drive '"${DRIVE}"' has been backed up. Check '"${HOME}"' for the file '"${BACKUP_FILE}"'.' 4
                            else
                                display_info 'The drive '"${DRIVE}"' could not be backed up.' 3
                            fi
                            ;;
                        $NO)
                            display_yesno 'The drive '"${DRIVE}"' will not be backed up. Do you wish to re-select a storage drive to burn the image to?'
                            RESPONSE=$?

                            case $RESPONSE in
                                $YES)
                                    FLAG=441
                                    ;;
                                $NO)
                                    FLAG=-441
                                    ;;
                                $ESC)
                                    display_message "Program stopped. Select <OK> to close."
                                    FLAG=-441
                                    ;;
                            esac
                            ;;
                        $ESC)
                            display_message "Program stopped. Select <OK> to close."
                            FLAG=-441
                            ;;
                    esac
                    ;;
                $ESC)
                    display_message "Program stopped. Select <OK> to close."
                    FLAG=-441
                    ;;
            esac

        done
    fi


    if [[ "${FLAG}" -eq 440 ]]
    then
        # Flag value at this point = 440 (on success)
        # Flag codes : [+/-]450[0,1]
        ############################################################  Writing image file to USB drive
        while [[ "${FLAG}" -gt 0 && "${FLAG}" -ne 450 ]]
        do
            DRIVE_DD="$( printf '%s' "${DRIVE}" | sed 's/disk/rdisk/g' )"

            display_info "The Linux image will now be written to the the USB drive. This will take a few minutes." 4
            display_info "After the USB has been written to, you may or may not get a prompt saying that the USB is not recognisable. If you do, click 'Ignore'." 6
            display_info "You will be prompted for the administrator/root password, if you are not running this program as admin/root." 5

            if [[ -e "${IMG}" ]]
            then
                if [[ $(whoami) = "root" ]]
                then
                    
                    if [[ $(uname) == "Darwin" ]]
                    then
                        ( pv -nW "${IMG}" | sudo /bin/dd of="${DRIVE_DD}" bs=4m && sync ) 2>&1 | display_gauge "Writing image to storage."
                    else
                        ( pv -nW "${IMG}" | sudo dd of="${DRIVE_DD}" bs=4M && sync ) 2>&1 | display_gauge "Writing image to storage."
                    fi

                    display_message 'Burning image to storage drive '"${DRIVE}"' completed.'
                    FLAG=450
                elif [[ $(whoami) != "root" ]]
                then
                    display_message "The password prompt for admin/root will be prompted at the terminal. Please enter the password on the next prompt."
                    
                    sudo -k
                    dialog --backtitle "Raspberry Pi Image Burner V0.1_alpha" --title "Authentication required" \
                        --passwordbox "[sudo] Password for user $USER : " 0 0 2>"${TEMP}" && printf "\\n" >>"${TEMP}"

                    if [ "$(uname)" == "Darwin" ]
                    then
#                        ( cat "${TEMP}" | sudo -S sudo su ) && ( pv -nW "${IMG}" | sudo /bin/dd of="${DRIVE_DD}" bs=4m && sync ) 2>&1 | \
#                            display_gauge "Writing to \"${DRIVE}\"." && printf "" >"${TEMP}"
						( ( sudo -S sudo su ) < "${TEMP}" ) && ( pv -nW "${IMG}" | sudo /bin/dd of="${DRIVE_DD}" bs=4m && sync ) 2>&1 | \
                            display_gauge 'Writing to '"${DRIVE}"'.' && printf "" >"${TEMP}"
                    else
#                        ( cat "${TEMP}" | sudo -S sudo su ) && ( pv -nW "${IMG}" | sudo dd of="${DRIVE_DD}" bs=4M && sync ) 2>&1 | \
#                            display_gauge "Writing to \"${DRIVE}\"." && printf "" >"${TEMP}"
						( ( sudo -S sudo su ) < "${TEMP}" ) && ( pv -nW "${IMG}" | sudo dd of="${DRIVE_DD}" bs=4M && sync ) 2>&1 | \
                            display_gauge 'Writing to '"${DRIVE}"'.' && printf "" >"${TEMP}"
                    fi
                    
                    display_message 'Burning image to storage drive '"${DRIVE}"' completed.'
                    sudo -k
                    FLAG=450
                fi
            else
                display_info "The '.img' file that is to be written to the disk could not be found." 5
                FLAG=-451
                display_message "Program stopped. Select <OK> to close."
            fi

            if [ "${FLAG}" -eq 450 ]
            then        
                diskutil eject "${DRIVE}"
                display_message 'The storage drive '"${DRIVE}"' has been ejected. The process is done. Select <OK> to close.'
                FLAG=-450
            fi
        done
    fi
    ############################################################ Image file written to USB drive
done

if [[ "${FLAG}" -eq -450 ]]
then
    FLAG=450
fi

############################################################ Configuring for SSH access and WiFi configuration
# Flag value at this point = -450 (on success)
if [[ "${FLAG}" -eq 450 ]]
then
    # Flag codes : [+/-]460[0,1]
    while [[ "${FLAG}" -gt 0 && "${FLAG}" -ne 460 ]]
    do
        display_yesno "Do you want to configure the Raspberry Pi \
            to be able to connect to it via SSH in a headless environment?\
            Also, do you wish to configure it to connect to a certain WiFi network?"
        RESP=$?

        case $RESP in
            $OK)
                W=(1 "SSH" off) ; W+=(2 "WiFi" off)
                dialog --no-collapse --clear --backtitle "Rapberry Pi Image Burner V0.1_alpha" --title "Pick the options you wish to enable" \
                    --checklist "Options" 0 0 0 "${W[@]}" 2>"${TEMP}"
                FLAG=460
                ;;
            $CANCEL)
                display_yesno "Exit Program?"
                RESPONSE=$?

                case $RESPONSE in
                    $YES)
                        display_message "Program ended. Select <OK> to close."
                        FLAG=-461
                        ;;
                    $NO)
                        FLAG=461
                        ;;
                    $ESC)
                        display_message "Program stopped. Select <OK> to close."
                        FLAG=-461
                        ;;
                esac
                ;;
            $ESC)
                display_message "Stopped. Select <OK>."
                display_yesno "Exit program?"
                RESPONSE=$?

                case $RESPONSE in
                    $YES)
                        FLAG=-461
                        display_message "Program ended. Select <OK> to close."
                        ;;
                    $NO)
                        FLAG=461
                        ;;
                    $ESC)
                        FLAG=-461
                        display_message "Program stopped. Select <OK> to close."
                        ;;
                esac
                ;;
        esac
    done

    # Flag value at this point = 460 (on success)
    if [[ "${FLAG}" -eq 460 ]]
    then
        OPTIONS="$( <"${TEMP}" )"

        # Flag codes : [+/-]47[1,0]
        ############################################################ USB drive selection (part-1) for SSH and WiFi configuration
        while [[ "${FLAG}" -gt 0 && "${FLAG}" -ne 470 ]]
        do
            display_message "If the pen-drive is attached to the computer, please remove it. Select <OK> when done."
            RESP=$?
            
            case $RESP in
                $OK)
                    diskutil list > "${COMP1}"
                    mount > "${MOUNT1}"
                    FLAG=470
                    ;;
                $CANCEL)
                    display_message "Cancelled. Select <OK>."
                    display_yesno "Exit Program?"
                    RESPONSE=$?

                    case $RESPONSE in
                        $YES)
                            display_message "Program ended. Select <OK> to close."
                            FLAG=-471
                            ;;
                        $NO)
                            FLAG=471
                            ;;
                        $ESC)
                            display_message "Program stopped. Select <OK> to close."
                            FLAG=-471
                            ;;
                    esac
                    ;;
                $ESC)
                    display_message "Stopped. Select <OK>."
                    display_yesno "Exit program?"
                    RESPONSE=$?

                    case $RESPONSE in
                        $YES)
                            FLAG=-471
                            display_message "Program ended. Select <OK> to close."
                            ;;
                        $NO)
                            FLAG=471
                            ;;
                        $ESC)
                            FLAG=-471
                            display_message "Program stopped. Select <OK> to close."
                            ;;
                    esac
                    ;;
            esac
        done

        # Don't need an if-statement here to check if the FLAG value at this point is 470 because the only way that the script
        # can progress to this point by exiting the previous while-loop is by either having a +480 value or a -481 value(in \
        # which case the script exits completely.)

        # Flag value at this point = 470 (on success)
        # Flag codes : [+/-]48[1,0]
        ############################################################ USB drive selection (part-2) for SSH and WiFi configuration
        while [[ "${FLAG}" -gt 0 && "${FLAG}" -ne 480 ]]
        do
            display_message "Insert the pen-drive/SD card that is to be written to. Select <OK> when done."
            RESPONSE=$?

            case $RESPONSE in
                $OK)
                    display_info "Recognising inserted pen-drive/SD card. Please wait." 4
                    diskutil list > "${COMP2}"
                    mount > "${MOUNT2}"
                    FLAG=480
                    ;;
                $CANCEL)
                    display_message "Exit program?"
                    RESPONSE=$?

                    case $RESPONSE in
                        $YES)
                            FLAG=-481
                            display_message "Program ended. Select <OK> to close."
                            ;;
                        $NO)
                            FLAG=481
                            ;;
                        $ESC)
                            FLAG=-481
                            display_message "Program stopped. Select <OK> to close."
                            ;;
                    esac
                    ;;
                $ESC)
                    display_message "Stopped. Select <OK>."
                    display_yesno "Exit program?"
                    RESPONSE=$?

                    case $RESPONSE in
                        $YES)
                            FLAG=-481
                            display_message "Program ended. Select <OK> to close."
                            ;;
                        $NO)
                            FLAG=481
                            ;;
                        $ESC)
                            FLAG=-481
                            display_message "Program stopped. Select <OK> to close."
                            ;;
                    esac
                    ;;
            esac

        done

        # Flag value at this point = 480 (on success)
        # Flag codes : [+/-]49[1,0]
        ############################################################ SSH and WiFi configuration
        while [[ "${FLAG}" -gt 0 && "${FLAG}" -ne 490 ]]
        do
            DRIVE="$( diff "${COMP1}" "${COMP2}" | grep -i '/dev/' | cut -d" " -f2 )"                                   # /dev/disk2 type
            MOUNT_DISK="$( diff "${MOUNT1}" "${MOUNT2}" | grep -i '/dev/disk' | cut -d" " -f2 )"                        # /dev/disk2s1 type
            MOUNT_DRIVE="$( diff "${MOUNT1}" "${MOUNT2}" | grep -i '/dev/disk' | cut -d" " -f4 | sed 's/\ /\\\ /g')"    # /Volumes/DRIVE type

            display_info 'The drive selected is '"${DRIVE}"' and it is mounted at '"${MOUNT_DRIVE}"'.' 3


            # If 'SSH and WiFi' or 'SSH only' or 'WiFi only' configuration was picked
            if [[ "${OPTIONS}" == "1 2" || "${OPTIONS}" == "1" || "${OPTIONS}" == "2" ]]
            then

                # If 'SSH and WiFi' or 'SSH only' configuration was picked
                if [[ "${OPTIONS}" == "1 2" || "${OPTIONS}" == "1" ]]
                then
                    display_yesno "The file required for SSH access will be created. Continue?"
                    RESPONSE=$?

                    case $RESPONSE in
                        $YES)
                            display_info 'Creating file named "ssh" on '"${DRIVE}"'.' 2
                            touch "${DRIVE}"/ssh
							SSH_FILE="$( ls "${DRIVE}"/ssh )"
                            
							# Checking if 'ssh' file was created
                            if [[ -f "${SSH_FILE}" ]]
                            then
								display_info 'File created on '"${DRIVE}"'.' 2
								FLAG=490
							else
								display_info "File could not be created." 2
								FLAG=-491
							fi

							;;

                        $NO)
                            display_message "Program stopped. Select <OK> to close."
                            FLAG=-491
                            ;;
                        $ESC)
                            display_message "Program stopped. Select <OK> to close."
                            FLAG=-491
                            ;;
                    esac
                fi

                # If 'SSH and WiFi' or 'WiFi only' configuration was picked
                if [[ "${OPTIONS}" == "1 2" || "${OPTIONS}" == "2" ]]
                then
                    display_yesno "Would you like to add WiFi network credentials so that the \
                        Raspberry Pi can connect to WiFi on boot? \
                        Select <YES> if you wish to SSH into the device and don't have access to\
                            an ethernet connection."
                    RESPONSE=$?

                    case $RESPONSE in
                        $YES)
                            dialog --backtitle "Raspberry Pi Image Burner V0.1_alpha" --title "WiFi Connection Configuration" --clear \
                                --inputbox "Enter name(SSID) of WiFi network" 0 0 2>"${TEMP}"
                            RESP=$?

                            case $RESP in
                                $OK)
                                    SSID="$( <"${TEMP}" )"
                                    touch "${DRIVE}"/wpa_supplicant.conf
									WIFI_FILE="$( ls "${DRIVE}"/wpa_supplicant.conf )"
                                    dialog --backtitle "Raspberry Pi Image Burner V0.1_alpha" --title "WiFi Connection Configuration" --clear \
                                        --inputbox "Enter password of WiFi network" 0 0 2>"${TEMP}"
                                    RESP=$?

                                    case $RESP in
                                        $OK)
                                            cat <<-EOF >"${WIFI_FILE}"
											ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
											update_config=1

											network={
												ssid='"${SSID}"'
												key-mgmt=WPA2-PSK
												psk='"$( cat "${TEMP}" )"'
											}
											EOF

											# Checking if 'wpa_supplicant.conf' file exists and is of non-zero size
											if [[ -s "${WIFI_FILE}" ]]
											then
												display_info "WiFi connection configured" 2
												FLAG=490
											else
												display_info "WiFi connection could not be configured" 2
												FLAG=-491
											fi

                                            ;;
                                        $CANCEL)
                                            display_yesno "Cancel WiFi connection configuration?"
                                            RESPONSE=$?

                                            case $RESPONSE in
                                                $YES)
                                                    display_message "Program stopped. Select <OK> to close."
                                                    FLAG=-491
                                                    ;;
                                                $NO)
                                                    display_message "Going back to configuring WiFi connection. Select <OK>."
                                                    FLAG=491
                                                    ;;
                                                $ESC)
                                                    display_message "Program stopped. Select <OK> to close."
                                                    FLAG=-491
                                                    ;;
                                            esac
                                            ;;

                                        $ESC)
                                            display_message "Program stopped. Select <OK> to close."
                                            FLAG=-491
                                            ;;
                                    esac
                                    ;;
                                $CANCEL)
                                    display_message "Cancel Key Pressed."
                                    FLAG=-491
                                    ;;
                                $ESC)
                                    display_message "Escape Key Pressed."
                                    FLAG=-491
                                    ;;
                            esac
                            ;;
                        $NO)
                            display_message "Exiting program. Select <OK>"
                            FLAG=-491
                            ;;
                        $ESC)
                            display_message "Program stopped. Select <OK> to close."
                            FLAG=-491
                            ;;
                    esac

                fi

            fi
            
        done
        
        # Flag value at this point = 490 (if successful)
        if [[ "${FLAG}" -eq 490 ]]
        then
            display_info "The device has now been configured for SSH access.\
                You can access the Raspberry Pi with the username 'pi'\
                and the password 'raspberry'.\
                Login using the following command:\
                ssh pi@[IP Address of Raspberry Pi]" 10
        fi

        # Ejecting drive at the end
        display_info "The disk will now be unmounted." 2
        diskutil unmountDisk "${DRIVE}" ; diskutil eject "${DRIVE}" || display_info "The drive \"${DRIVE}\" could not be ejected.\
            Try ejecting it manually."

    fi
fi
#### End of script
