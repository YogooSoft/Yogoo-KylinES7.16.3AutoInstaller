#!/bin/bash
currentdir=$(pwd)
echo "##############install ansible start ##############"

echo $currentdir
tar xjf portable-ansible-v0.4.0-py3.tar.bz2
ln -s ansible/ ansible-playbook

echo "alias ansible='python3 $currentdir/ansible'" >> /etc/profile
echo "alias ansible-playbook='python3 $currentdir/ansible-playbook'" >> /etc/profile
source /etc/profile

mkdir /etc/ansible/
touch /etc/ansible/ansible.cfg
echo "[defaults]" >> /etc/ansible/ansible.cfg
echo "deprecation_warnings = False" >> /etc/ansible/ansible.cfg
echo "command_warnings = False" >> /etc/ansible/ansible.cfg
echo "##############install ansible end ################"
