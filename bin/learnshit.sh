#!/bin/bash
# Reads a given directory and picks a random file.

# The directory you want to use. You could use "$1" instead if you
# wanted to parametrize it.
DIR="/usr/share/man/man1"
# DIR="$1"

# Internal Field Separator set to newline, so file names with
# spaces do not break our script.
IFS='
'
 
if [[ -d "${DIR}" ]]
then
  # Runs ls on the given dir, and dumps the output into a matrix,
  # it uses the new lines character as a field delimiter, as explained above.
  file_matrix=($(ls "${DIR}"))
  num_files=${#file_matrix[*]}
  # This is the command you want to run on a random file.
  # Change "ls -l" by anything you want, it's just an example.
  man `echo "${file_matrix[$((RANDOM%num_files))]}" | gawk '{print substr( $0, 0, index($0, ".1.gz")-1 )}'`
fi

exit 0
