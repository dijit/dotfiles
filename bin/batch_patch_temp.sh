#!/bin/sh

# Desc batch patch code
# who when      what
# AP  20110427  Created


#Functions

function askuser {
T=0
while [ $T -eq 0 ]; do
  read PROCEED
  PROCEED=$(echo $PROCEED | tr [:upper:] [:lower:])
  if [ "$PROCEED" == "y" ]; then
    echo "Continuing..."
    T=1
  elif [ "$PROCEED" == "n" ]; then
   echo "Exiting on user request"
   exit 1
  fi
done
}

#Determine DC and set codepath

echo "NOTE: Script assumes code is already deployed..."

if [ $(hostname | grep sc9 | wc -l) -eq 1 ]
  then
   DCPATH=/mnt/web
   CODEPATH=/mnt/code
  else
   DCPATH=/web/01
   CODEPATH=$DCPATH/code
fi

OLDCODEINST=$1
NEWCODEINST=$2

if [ ! $OLDCODEINST -o ! $NEWCODEINST ]; then 
 echo "Usage: $0 OLDCODEINST NEWCODEINST - dont run as sudo!!"
 exit 1
fi

echo "Please authenticate for sudo..."
sudo echo

#Grab list of clients on old code instance
TMP_SITE_LIST=$(for i in $(sudo instmaint codeinst list $OLDCODEINST | egrep "^\W" | egrep -o "\w.*"); do echo -n "$i "; done)

for site in $TMP_SITE_LIST; do 
  echo -n "Do you wish to move $site?? [Y/N]" 
  T=0
  while [ $T -eq 0 ]; do
    read PROCEED
    PROCEED=$(echo $PROCEED | tr [:upper:] [:lower:])
    if [ "$PROCEED" == "y" ]; then
      SITE_LIST="$SITE_LIST $site"
      T=1
    elif [ "$PROCEED" == "n" ]; then
      T=1
    fi
  done
done

#Create list of servers old code runs on
SERVER_LIST=$(ls -d $DCPATH/apache/hosts/*/$OLDCODEINST | cut -d \/ -f 6)

#Get new apache pool
echo "Figuring out new apache port for code pool"
echo "Last 5 current ports;"
grep -h '^Listen' $DCPATH/apache/pools/*/httpd.conf | sed s/\$INTIP://g | sed s/Listen\ //g | grep -v WEBNUM | egrep "^8" | sort -n | tail -n 5
PORT=$(expr 1 + $(grep -h '^Listen' $DCPATH/apache/pools/*/httpd.conf | sed s/\$INTIP://g | sed s/Listen\ //g | grep -v WEBNUM | egrep "^8" | sort -n | tail -n 1))

echo "Please  check the following details:"
echo "Old code instance : $OLDCODEINST"
echo "New code instance : $NEWCODEINST"
echo "New apache port : $PORT"
echo "Clients being updated; $SITE_LIST"

echo "Do you wish to proceed with the batch move? [Y/N]"
askuser 
echo Runnning "sudo $DCPATH/apache/bin/add_pool.pl -n $NEWCODEINST -p $PORT -A httpd-2.2"
Create new apache pool
sudo $DCPATH/apache/bin/add_pool.pl -n $NEWCODEINST -p $PORT -A httpd-2.2
#Create vhost folders
echo "Assigning webs to pool..."
for i in $SERVER_LIST; do sudo mkdir -pv $DCPATH/apache/hosts/$i/$NEWCODEINST/vhosts ; done


if [ $(hostname | grep sc9 | wc -l) -eq 1 ]
  then
   for i in /mnt/web/{lock,cache}/$NEWCODEINST; do sudo mkdir -pv $i; sudo chmod -vc 0755 $i; sudo chown -vc apache:apache $i; ls -ld $i; done
  else

echo "Now you need to Log into filer01 in a seperate terminal:"
echo "from malkuth: ssh root@filer01 (password in usual place)"
echo "Run the following commands;"
echo "qtree create /vol/cache/$NEWCODEINST"
echo "qtree create /vol/applocks/$NEWCODEINST"
echo "After this has been done you may continue"
echo "Press [Y/N] to proceed"
askuser
sudo ln -sfv /web/locks/$NEWCODEINST /web/01/lock/$NEWCODEINST
sudo chmod -c 0755 /web/{locks,cache}/$NEWCODEINST
sudo chown -c apache:apache /web/{locks,cache}/$NEWCODEINST

fi

echo "Ok to check new pool? [Y/N]"
askuser
echo "Checking new pool..."
sudo $DCPATH/apache/bin/apachectl check $NEWCODEINST
echo "Ok to start pool? [Y/N]"
askuser
sudo $DCPATH/apache/bin/apachectl start $NEWCODEINST


#Copying symlinks to new code version
echo "Ok to copy symlinks to new code version? [Y/N]"
askuser
echo "Copying symlinks to new code version"
for i in $SITE_LIST; do sudo cp -dv $DCPATH/conf/$OLDCODEINST/$i.ini $DCPATH/conf/$NEWCODEINST; done


#Entprs update
echo "Perform Enterprise update? [Y/N]"
askuser
for i in $SITE_LIST; do sudo /opt/admin/bin/instmaint entprs update $i --codeinst=$NEWCODEINST 2>&1; done


#Move vhosts
echo "Do you wish to move the vhosts to from $OLDCODEINST to $NEWCODEINST? [Y/N]"
askuser

for i in $SITE_LIST; do sudo mv -v $DCPATH/apache/pools/$OLDCODEINST/vhosts/$i.vhost $DCPATH/apache/pools/$NEWCODEINST/vhosts/; done

#Check Code instances
echo "Ok to check code instances? [Y/N]"
askuser
echo "Checking apache code instances"
sudo -u apachectl shmux -M 4 -p -c "sudo /etc/init.d/httpd check $OLDCODEINST; sleep 3 ; sudo /etc/init.d/httpd check $NEWCODEINST" $SERVER_LIST

#Restart code instances
echo "Do you wish to restart the apache code instances? [Y/N]"
askuser
sudo -u apachectl shmux -M 4 -p -c "sudo /etc/init.d/httpd restart $OLDCODEINST; sleep 3 ; sudo /etc/init.d/httpd restart $NEWCODEINST" $SERVER_LIST


#Cleanup enterprise & Remove old ini's
#instmaint entprs move done twice as 1st time doesnt work
echo "Do you wish to perform the site cleanup? [Y/N]"
askuser
for site in $SITE_LIST; do sudo /opt/admin/bin/instmaint entprs move $site --codeinst=$NEWCODEINST; sudo /opt/admin/bin/instmaint entprs move $site --codeinst=$NEWCODEINST; sudo rm -vf $DCPATH/conf/$OLDCODEINST/$site.ini; done


echo "FIN"
