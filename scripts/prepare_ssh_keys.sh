#!/usr/bin/bash

# Prepare SSH keys
rm -f ~/.ssh/id_rsa*
ssh-keygen -N "" -f ~/.ssh/id_rsa
echo "StrictHostKeyChecking=no" >> ~/.ssh/config
for host in worker1.preferred.domain.com worker2.preferred.domain.com  # EDIT
do
  ssh-keyscan -H $host >> ~/.ssh/known_hosts
  sshpass -p passw0rd ssh-copy-id -i ~/.ssh/id_rsa.pub $host
done
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys