#! /bin/bash
# The intention of this script is to first copy itself to the target machines, then call itself with a special flag. (probably --local-audit)
# it is not complete and has been stalled for a very long time.
# in fact there are much easier ways to do this using cfengine.

# Check for a bin directory on the target system; even if it doesn't exist, create it.
# copy myself over to host:~/bin

# Make absolute name filename.
Myself=$()

if [ $1 == "--local-audit"]; then
    :
else
    for host in $@; do # Grab some hostnames from the command line ( $@ is everything after the script name )
    ssh $host [ -d ~/bin ] && echo "Hey, directory is here" || mkdir ~/bin # Check ~/bin folder exists, if not create it
    scp $0 ${host}:~/bin # Move script over to host ( $0 is the name of the script ) might not be relative to localpath.. :/ doesn't check full paths..
    	# Run shmux on all machines.
    	## Setting Ownership
    	ssh $host chmod u+x ~/bin/${0}
    	## Executing script from remote location with the local-audit parameter.
		ssh $host ~/bin/${0} --local-audit
		# Bring her home!
		scp $host:/tmp/$(whoami)-audit.log.out ./audit.${host}.txt
	done
    exit 0 # After the local loop, exit to avoid running the local audit on the host you ran this from.
    echo "Failed to kill myself";
    exit 255
fi

# is the output file existing already.
if [ -f /tmp/$(whoami)-audit.log.out ]; then
 echo "File exists"
 rm /tmp/$(whoami)-audit.log.out || echo "error removing old file are you sure you own it?";
fi

audit="/tmp/$(whoami)-audit.psv"
echo "hostname|operatingsystem|architecture|vendor|model|serial|cpu|memory";

# Authenticate for sudo:
sudo id >>/dev/null || echo "Sudo Failed, exiting gracefully" && exit 255

# this is where the magic happens, just grab all the variables and stuff.

myhost=\$(hostname || uname -n)
myos=\$(cat /etc/*release)
myarch=\$(uname -i)
#mybios=\$(sudo /usr/sbin/dmidecode -t 1)
myvendor=\$(sudo /usr/sbin/dmidecode -t 1 | grep Manufact | cut -d\: -f2)
mymodel=\$(sudo /usr/sbin/dmidecode -t 1 | grep Product\ Name | cut -d\: -f2)
myserial=\$(sudo /usr/sbin/dmidecode -t 1 | grep Serial | cut -d\: -f2)
#mybioscpu=\$(sudo /usr/sbin/dmidecode -t 4)
mycpuvendor=\$(sudo /usr/sbin/dmidecode -t 4 | grep Manufacturer | cut -d\: -f2 | head -n 1)
mycpufamily=\$(sudo /usr/sbin/dmidecode -t 4 | grep Family | cut -d\: -f2 | head -n 1)
mycpuspeed=\$(sudo /usr/sbin/dmidecode -t 4 | grep Max\ Speed | cut -d\: -f2 | head -n 1)
mymaxmem=\$(sudo /usr/sbin/dmidecode -t 16 | grep Max | cut -d\: -f2)
mymem=\$(sudo /usr/sbin/dmidecode -t 19 | grep Range | tail -n 1 | cut -d\: -f2);

echo \$myhost\|\$myos\|\$myarch\|\$myvendor\|\$mymodel\|\$myserial\|\$mycpuvendor \$mycpufamilry \$mycpuspeed\|\$mymem \(\$mymaxmem \- max\) \
| tee /tmp/$(whoami)-audit.log.out;

cat /tmp/$(whoami)-audit.log.out | grep \| | cut -d\: -f2- | sed 's/^\ //ig' > ${AUDIT}

echo
echo "-----------------------------------------"
echo " Audit script finished                   "
echo "-----------------------------------------"
echo "${AUDIT} ready."
echo

