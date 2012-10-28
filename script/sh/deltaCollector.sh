#!/bin/sh -e
# This script collects the delta between to given directories

deltaCollector() {
	if [ -d "$1" -a -d "$2" ]
	then :
	else
		echo
		echo "usage: $0 new_release_dir old_release_dir target_tmp_dir"
		echo
		return 1
	fi

	if [ -d "$3" ]
	then
		echo
		echo "temp delta directory already exists: $3"
		echo
		return 1
	else
		mkdir -p "$3"
	fi

	echo
	echo "collecting delta: "
	echo "-------------------------------"
	rsync --recursive --dry-run --itemize-changes "$1/" "$2/" | awk '{print $2}' | while read i
	do
		curfile="$1/$i"
		tar --create --no-recursion "$curfile" | tar --extract --directory "$3" --same-permissions  
		echo "Copy file: $curfile"
	done

	echo "Finished copying new files to: $3"
	echo "-------------------------------"

	echo "Looking for removed files"
	echo "-------------------------------"

	rsync --dry-run --delete-after --recursive --progress "$1/" "$2/" | grep deleting | awk '{print $2}' | while read i
	do
#		curfile="$2/$i"
		curfile="./$i"
		echo "$curfile" >> "$3/removedFiles.txt"
 		echo "Removed File: $curfile"
	done
  touch $3/removedFiles.txt
	echo "removed files are listed in $3/removedFiles.txt"

	echo "-------------------------------"
	return 0
}

deltaCollector $*
