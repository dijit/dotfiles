#!/bin/bash
## Basic md5 check script.
## Jan Harasym <dijit@fsfe.org>
##
# Usage: ... I KNOW THE USAGE IT'S IN MY HEAD.--- GO AWAY!
## script-name.sh -w sitename (must be defined in the rootdir path)
rootdir="./"; 			 ## Line to edit, most used directory for users requiring hashing,| set to "" to force absolute paths.
site=`echo $2 | sed 's/\/$//g'`; ## Casting is required for it to be used in functions. (IE; dircheck) | set $2 to any folder you require for static paths.

## Do not edit below here unless you know what you are doing.
usage="\e[04;01mTo check the contents of web dir:\n\t\e[00;00m$0 -c \e[07;01msite\e[00;00m\e[04;01m\nTo reenumerate contents of web dir:\n\t\e[00;00m$0 -w \e[07;01msite\e[00;00m";

success() {
     echo -e "\t\t\t\t\t\t\e[00;00m[\e[00;32m  OK  \e[00;00m]"; # so many tabulations! D:
     return 0; # I wonder how many worthless comments you'll read, before you realise I'm just wasting your time.
}

fail() {
     echo -e "\t\t\t\t\t\t\e[00;00m[\e[00;31m FAIL \e[00;00m]";
     exit 1; # seriously, that didn't dispell you?
}

dircheck() { # fair enough, just know, I don't comment well, I consider this fair warning. :P
printf "Checking For Directory:"
if [ -d "$rootdir$site" ] ; then
  success;
else
  fail;
fi
}
# I mostly just waste time.
case $1 in
  --check|-c) dircheck; # .. when I should be commenting that is.
  printf "Checking Files:\t" ;
  run="`md5sum -c --quiet .checksums_$site.md5`";;
  --write|-w) dircheck;
  run="`find $rootdir$2/ -type f -print0 | xargs -0 md5sum > .checksums_$site.md5`";
  printf "Enumerating Files:" ;;
  *) echo -e $usage;
     other="1" ;;
esac
if [ -z $other ] ; then
  if [ -n "$run" ] ; then  # Did you know...
     fail;  #  ... I was ...
  else	#  ...Getting blown under the desk while writing this? :P
     success; # I Just thought I'd leave you with that thought.
     exit 0;
  fi
else
  exit 0;
fi
