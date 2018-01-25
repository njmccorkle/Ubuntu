#!/bin/bash
#
# This script does all mccorkle.co post install setup tasks.

verify_root() {
    # Verify running as root:
	echo "Verifying root"
    if [ "$(id -u)" != "0" ]; then
        if [ $# -ne 0 ]; then
            echo "Failed running with sudo. Exiting." 1>&2
            exit 1
        fi
        echo "This script must be run as root. Trying to run with sudo."
        sudo bash "$0" --with-sudo
        exit 0
    fi
}

#verify_args () {
#	echo "Verifying args "
#	echo $#
#	if [ $# -ne 1 ]; then
#		echo "Please include a hostname."
#		exit 1
#fi
#}

install_system_packages() {
	echo "Updating and installing system packages"
    apt-get -y update
	apt-get -y upgrade
	apt-get -y autoremove
    # Base packages
    apt-get -y install openssh-server open-vm-tools ufw

	ufw default deny incoming
	ufw default allow outgoing
	# add force here
	ufw allow openssh
	ufw enable
}

install_snmpd () {
	echo "Installing snmpd"
	apt-get -y install snmpd
	# need to wget snmpd.conf
	# add force here
	ufw allow snmp
	ufw reload
	cp snmpd.conf /etc/snmp/snmpd.conf
	service snmpd restart
}

set_hostname () {
	echo "Setting hostname"
	cp /etc/hosts /etc/hosts.bak
	cp /etc/hostname /etc/hostname.bak
	
	sed 's/ubuntu/$1/g' /etc/hosts > /etc/hosts
	echo $1 > /etc/hostname
	
	ifdown ens160 && ifup ens160
}

verify_root
#verify_args
install_system_packages
install_snmpd
set_hostname
