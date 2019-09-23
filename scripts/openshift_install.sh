#!/usr/bin/bash

# OpenShift install
yum install -y openshift-ansible

rm -rf ~/openshift-ansible/inventory/
mkdir -p ~/openshift-ansible/inventory/
touch ~/openshift-ansible/inventory/hosts

cat << EOF >> ~/openshift-ansible/inventory/hosts
[OSEv3:children]
masters
nodes
etcd

[OSEv3:vars]
openshift_deployment_type='openshift-enterprise'

# system_images_registry="registry.access.redhat.com/openshift3/"

ansible_user=root
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

openshift_disable_check=package_version,disk_availability,docker_storage,memory_availability

openshift_master_identity_providers=[{'name': 'allow_all', 'login': 'true', 'challenge': 'true', 'kind': 'AllowAllPasswordIdentityProvider'}]
openshift_auth_type=allowall

oreg_auth_user=<rhel_subscription_username> 
oreg_auth_password=<rhel_subscription_password>  

osm_default_subdomain=apps.preferred.subdomain.com

openshift_master_dynamic_provisioning_enabled=true

debug_level=5

[masters]
master.preferred.domain.com 

[etcd]
master.preferred.domain.com 

[nodes]
master.preferred.domain.com  openshift_node_group_name="node-config-master-infra"
worker1.preferred.domain.com  openshift_node_group_name="node-config-compute"
worker2.preferred.domain.com  openshift_node_group_name="node-config-compute"
EOF

cd /usr/share/ansible/openshift-ansible
ansible-playbook -i ~/openshift-ansible/inventory/hosts playbooks/prerequisites.yml
ansible-playbook -i ~/openshift-ansible/inventory/hosts playbooks/deploy_cluster.yml

# Set admin user password
mkdir -p /etc/origin/master
htpasswd -cb /etc/origin/master/htpasswd admin <strong_password>  # EDIT

# Add cluster roles to admin
oc login -u system:admin
oc adm policy add-cluster-role-to-user cluster-admin admin
oc adm policy add-cluster-role-to-user storage-admin admin

# Create NFS export
lvcreate -L 30G -n export rhel
mkfs.xfs /dev/mapper/rhel-export
mkdir /export
mount /dev/mapper/rhel-export /export/
cat << EOF >> /etc/exports
/export
EOF
systemctl restart nfs-server