#!/usr/bin/env awk -f

BEGIN {

	printf("%-10s\t%s\n", "Capacity", "Device")

	while ("system_profiler SPUSBDataType" | getline) {
		if (/Capacity:/) {c=$2$3}
#		if (/Removable Media:/) {r=$3}
		if (/BSD Name:/) {n=$3}
		if (/USB Interface:/) {printf("%-10s\t%s\n", c, n)}
	}
}
