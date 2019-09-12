#!/usr/bin/bash

# Prepare RHEL
echo "Starting RHEL customization and Pre-requisite software installation"
hostnamectl set-hostname $(hostname -s).preferred.domain.com   # EDIT

echo "vm.max_map_count = 262144" |  tee --append /etc/sysctl.conf > /dev/null
sysctl -p
subscription-manager register --username=<rhel_subscription_username> --password=<rhel_subscription_username> --force # EDIT
subscription-manager refresh

subscription-manager attach --pool=<openshift_pool_ID> # EDIT

subscription-manager repos --disable="*" 

subscription-manager repos \
    --enable="rhel-7-for-power-le-rpms" \
    --enable="rhel-7-for-power-le-extras-rpms" \
    --enable="rhel-7-for-power-le-optional-rpms" \
    --enable="rhel-7-server-ansible-2.6-for-power-le-rpms" \
    --enable="rhel-7-for-power-le-ose-3.11-rpms" \
    --enable="rhel-7-for-power-le-fast-datapath-rpms" \
    --enable="rhel-7-server-for-power-le-rhscl-rpms"

yum install -y wget git net-tools bind-utils atomic-openshift-sdn-ovs-3.11* iptables-services python-firewall bridge-utils bash-completion kexec-tools sos psacct lvm2* httpd-tools vim sshpass yum-utils
yum update -y --skip-broken 
yum remove -y ansible
yum install -y ansible-2.6*
yum remove -y docker-ce docker docker-engine docker.io
yum install -y docker-1.13.1 
groupadd -f docker
usermod -aG docker $USER
sed -i.bak "s/OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false'/OPTIONS='--signature-verification=false --insecure-registry=172.30.0.0\/16 --log-opt max-size=1M --log-opt max-file=3 --disable-legacy-registry=true'/" /etc/sysconfig/docker
systemctl enable docker
systemctl stop docker
rm -rf /var/lib/docker/*
systemctl restart docker
systemctl is-active docker
rm -f /etc/modules-load.d/xen-netfront.conf

systemctl enable NetworkManager
systemctl start NetworkManager

# Set up NTP
yes | cp /etc/chrony.conf /etc/chrony.conf.orig
cat << EOF > /etc/chrony.conf
server 10.103.0.2
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony
EOF
systemctl restart chronyd