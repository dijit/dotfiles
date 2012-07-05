HOST=$1

ssh $HOST ssh-keygen -r $HOST -f /etc/ssh/ssh_host_rsa_key
ssh $HOST ssh-keygen -r $HOST -f /etc/ssh/ssh_host_dsa_key
