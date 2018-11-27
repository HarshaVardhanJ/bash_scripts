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
		mkdir -p "${MOUNT_POINT}" && \
			printf '%s' "${MOUNT_POINT}" && \
			exit 0
	fi

}


# Function that runs the installer script for 'fuse-ext2'
function install_fuse_ext2() {

	# Writing installation script to file
	local TEMP_DIR="$(mktemp -d fuse-ext2.xxx)"
	local SCRIPT_NAME="fuse-ext2-install.sh"
	local INSTALL_SCRIPT="${TEMP_DIR}"/"${SCRIPT_NAME}"

	# Changing to temp directory and creating installation script file
	cd "${TEMP_DIR}" && \
		cat <<EOF> "${INSTALL_SCRIPT}"
export PATH=/opt/gnu/bin:$PATH
export PKG_CONFIG_PATH=/opt/gnu/lib/pkgconfig:/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

mkdir fuse-ext2.build
cd fuse-ext2.build

if [ ! -d fuse-ext2 ]; then
    git clone https://github.com/alperakcan/fuse-ext2.git
fi

# m4
if [ ! -f m4-1.4.17.tar.gz ]; then
    curl -O -L http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz
fi
tar -zxvf m4-1.4.17.tar.gz
cd m4-1.4.17
./configure --prefix=/opt/gnu
make -j 16
sudo make install
cd ../

# autoconf
if [ ! -f autoconf-2.69.tar.gz ]; then
    curl -O -L http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
fi
tar -zxvf autoconf-2.69.tar.gz
cd autoconf-2.69
./configure --prefix=/opt/gnu
make
sudo make install
cd ../

# automake
if [ ! -f automake-1.15.tar.gz ]; then
    curl -O -L http://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz
fi
tar -zxvf automake-1.15.tar.gz
cd automake-1.15
./configure --prefix=/opt/gnu
make
sudo make install
cd ../

# libtool
if [ ! -f libtool-2.4.6.tar.gz ]; then
    curl -O -L http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz
fi
tar -zxvf libtool-2.4.6.tar.gz
cd libtool-2.4.6
./configure --prefix=/opt/gnu
make
sudo make install
cd ../

# e2fsprogs
if [ ! -f e2fsprogs-1.43.4.tar.gz ]; then
    curl -O -L https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.43.4/e2fsprogs-1.43.4.tar.gz
fi
tar -zxvf e2fsprogs-1.43.4.tar.gz
cd e2fsprogs-1.43.4
./configure --prefix=/opt/gnu --disable-nls
make
sudo make install
sudo make install-libs
sudo cp /opt/gnu/lib/pkgconfig/* /usr/local/lib/pkgconfig
cd ../

# fuse-ext2
export PATH=/opt/gnu/bin:$PATH
export PKG_CONFIG_PATH=/opt/gnu/lib/pkgconfig:/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

cd fuse-ext2
./autogen.sh
CFLAGS="-idirafter/opt/gnu/include -idirafter/usr/local/include/osxfuse/" LDFLAGS="-L/opt/gnu/lib -L/usr/local/lib" ./configure
make
sudo make install
EOF

	# If script exists, run it
	if [[ -s "${INSTALL_SCRIPT}" ]]
	then
		chmod u+x "${INSTALL_SCRIPT}" && \
			"${INSTALL_SCRIPT}" && \
			cd ../
		exit 0
	else
		printf '\n%s\n' "Installation script could not be found."
		exit 1
	fi

	# Cleanup. Removing temporary directory and created files
	for FILE in "${TEMP_DIR}"
	do
		rm -r "${FILE}"
		unset -v "${FILE}"
	done

}


# Function that checks dependencies and if 'fuse-ext2' is installed
function check_installation() {

	# If the 'fuse-ext2' package is accessible
	if [[ "$(which fuse-ext2)" ]]
	then
		 return 0
	# If 'fuse-ext2' is not installed, ask user.
	else
		read "The 'fuse-ext2' package could not be found. Would you like to install it?" REPLY

		case "${REPLY}" in
			y|Y)
				printf '\n%s\n' "Checking if Homebrew is installed."
				
				# If Homebrew is installed and is accessible
				if [[ "$(which brew)" ]]
				then
					printf '\n%s\n' "Homebrew is installed. Installing the cask 'osxfuse' as a dependency"

					# If 'homebrew/cask' has been tapped
					if [[ "$(brew tap | grep 'homebrew/cask')" ]]
					then
						brew cask install osxfuse 1>/dev/null 2>&1
					else
						brew tap homebrew/cask 1>/dev/null 2>&1 && \
							brew cask install osxfuse 1>/dev/null 2>&1
					fi

					# If 'osxfuse' has been installed
					if [[ "$(brew cask list | grep 'osxfuse')" ]]
					then
						printf '\n%s\n' "Installing 'fuse-ext2' now. You will see a lot of text and warnings scroll by. \
							This is normal. You will be prompted for the administrator's password while the script is executing." && \
							sleep 5
						# Calling function that runs the 'fuse-ext2' installer script
						install_fuse_ext2
					else
						printf '\n%s\n%s\n' "'osxfuse' is not installed. Please try and install it by running" "brew cask install osxfuse"
						exit 1
					fi
				else
					printf '\n%s\n' "Homebrew is not installed."
					exit 1
				fi
				;;
			n|N|*)
				printf '\n%s\n' "Not installing the 'fuse-ext2' package. Exiting"
				exit 1
				;;
		esac
	fi
}

# Function that mounts the EXTFS volume to the predefined mount point.
function mount_disk() {

	# Calling the function that checks if 'fuse-ext2' is installed
	check_installation

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
