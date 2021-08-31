#!/bin/bash
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# Copy Shared Library Dependencies           [Thomas Lange <code@nerdmind.de>] #
#                               [Edoardo Bezzeccheri <e.bezzeccheri@gmail.com] #
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#                                                                              #
# This script copies all shared library dependencies from a binary source file #
# to a desired target directory. 	                                       #
#                                                                              #
# OPTION [-b]: Full path to the binary whose dependencies shall be copied.     #
# OPTION [-t]: Full path to the target directory for the dependencies.         #
# OPTION [-r]: Regex passed to AWK to filter dependencies.                     #
#                                                                              #
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#===============================================================================
# Parsing command-line arguments with the getopts shell builtin
#===============================================================================
while getopts :b:t:r: option
do
	case $option in
		b) ARGUMENT_BINARY="$OPTARG" ;;
		t) ARGUMENT_TARGET="$OPTARG" ;;
		r) FILTER_REGEX="$OPTARG" ;;
	esac
done

#===============================================================================
# Checking if all required command-line arguments are provided
#===============================================================================
[ -z "${ARGUMENT_BINARY}" ] && echo "$0: Missing argument: [-b binary]" >&2
[ -z "${ARGUMENT_TARGET}" ] && echo "$0: Missing argument: [-t target]" >&2

#===============================================================================
# Abort execution if required command-line argument is missing
#===============================================================================
[ -z "${ARGUMENT_BINARY}" ] || [ -z "${ARGUMENT_TARGET}" ] && exit 1

#===============================================================================
# Checking if binary or target path does not exists and abort
#===============================================================================
[ ! -f "${ARGUMENT_BINARY}" ] && echo "$0: Binary path does not exists." >&2 && exit 1
[ ! -d "${ARGUMENT_TARGET}" ] && echo "$0: Target path does not exists." >&2 && exit 1

#===============================================================================
# Copy each library with its parent directories to the target directory
#===============================================================================
for library in $(ldd "${ARGUMENT_BINARY}" | cut -d '>' -f 2 | awk '/'${FILTER_REGEX}'/{print $1}')
do
	[ -f "${library}" ] && cp --verbose "${library}" "${ARGUMENT_TARGET}"
done
