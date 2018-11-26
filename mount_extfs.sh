#!/usr/bin/env bash
#
#: Title        :   mount_extfs.sh
#: Date         :   26-Nov-2018
#: Author       :   "Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :   1.0 (Stable)
#: Description  :   This script checks for a volume of type Linux
#                   and tries to mount it to a predefined directory
#                   using the 'fuse-ext2' utility.
#                
#: Options      :   None
#: Usage        :   Call the script.
#                                  ./mount_extfs.sh
################



# Function that creates a defined mount point for mounting the EXTFS volume.
# If the directory does not exist, it is created.
function mount_point() {

	# Parent directory of mount point
	local MOUNT_PARENT_DIR="$(ls -d ~/Desktop)"

	# Directory where EXT filesystem is to be mounted
	local MOUNT_DIR="extfs_mount"

	# Complete path to mount point
	local MOUNT_POINT="${MOUNT_PARENT_DIR}"/"${MOUNT_DIR}"

	# If the 'MOUNT_POINT' directory exists
	if [[ -d "${MOUNT_POINT}" ]]
	then
		printf '%s' "${MOUNT_POINT}"
		exit 0
	# If the 'MOUNT_POINT' directory does not exist, create it
	else
		mkdir -vp "${MOUNT_POINT}"
		printf '%s' "${MOUNT_POINT}"
		exit 0
	fi

}

# Function that mounts the EXTFS volume to the predefined mount point.
function mount_disk() {

	# Getting the mount point from the 'mount_point' function
	local MOUNT_POINT="$(mount_point)"

	# If the 'MOUNT_POINT' variable has been set and is not an empty string
	if [[ -v MOUNT_POINT && -n "${MOUNT_POINT}" ]]
	then
		# Local variable to store the volume to be mounted
		local MOUNT_DISK="$(diskutil list | grep "Linux" | awk '{print $5}')"
		local MOUNT_PREFIX="/dev/"

		# If the 'MOUNT_DISK' variable has been set and is not an empty string
		if [[ -v MOUNT_DISK && -n "${MOUNT_DISK}" ]]
		then
			# If the 'fuse-ext2' utility exists and is accessible
			if [[ $(which fuse-ext2) ]]
			then 
				# If the script is not run with root privileges
				if [[ "$(whoami)" != "root" ]]
				then
					printf '\n%s\n' "The next command will be run with 'sudo'. You will be prompted for the password." && sleep 2
				fi

				# Command that mounts the volume "${MOUNT_DISK}" at the mount point "${MOUNT_POINT}" as read-write
				sudo fuse-ext2 "${MOUNT_PREFIX}""${MOUNT_DISK}" "${MOUNT_POINT}" -o rw+
			# If the 'fuse-ext2' utility is not accessible
			else
				printf '\n%s\n' "The 'fuse-ext2' package could not be found within the PATH. Please check if it is installed."
				exit 1
			fi
		# If the 'MOUNT_DISK' variable could not be set
		else
			printf '\n%s\n' "A volume of type 'Linux' could not be found. Please check if the USB drive is inserted and recognised."
			exit 1
		fi
	# If the 'MOUNT_POINT' variable could not be set
	else
		printf '\n%s\n' "The mount point could not be set."
		exit 1
	fi

}

# Calling the 'mount_disk' function
mount_disk

# End of script
