#!/bin/bash
#
# This script does all mccorkle.co post install setup tasks.

verify_root() {
	# Verify running as root:
	echo "Verifying root"
	if [ "$(id -u)" != "0" ]; then
		echo "This script must be run as root. Please try again."
		exit 1
	fi
}

verify_args () {
        if [ "$#" -ne 1 ]; then
                echo "please include a hostname."
                exit 1
        fi
}

install_system_packages() {
        echo "Updating and installing system packages"
        apt-get -y update
        apt-get -y upgrade
        apt-get -y autoremove
        # Base packages
        apt-get -y install openssh-server open-vm-tools ufw vim

        #ufw firewall
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow openssh
        ufw --force enable
}

install_snmpd () {
        echo "Installing snmpd"
        apt-get -y install snmpd
        wget https://raw.githubusercontent.com/njmccorkle/Ubuntu/master/PostInstall/snmpd.conf
        cp snmpd.conf /etc/snmp/snmpd.conf
        service snmpd restart

        ufw allow snmp
        ufw reload
}

set_hostname () {
	echo "setting hostname to "$1" "
        cp /etc/hosts /etc/hosts.bak
        cp /etc/hostname /etc/hostname.bak

        sed 's/ubuntu/'"$1"'/g' /etc/hosts > /etc/hosts.new
		mv /etc/hosts.new /etc/hosts

		echo "$1" > /etc/hostname

        ifdown ens160 && ifup ens160
 }
 
 install_filebeat() {
 	echo "Installing Filebeat"
	# Create Beats source list
	echo "deb https://packages.elastic.co/beats/apt stable main" |  sudo tee -a /etc/apt/sources.list.d/beats.list

	#Get Elasticsearch GPG key
	wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

	#Update repos and install filebeat
	apt-get update
	apt-get install filebeat

	#download and move filebeat configuration
	wget -qO https://raw.githubusercontent.com/njmccorkle/Ubuntu/master/PostInstall/filebeat/filebeat.yml
	cp filebeat.yml /etc/filebeat/filebeat.yml

	#move private key
	wget -qO https://raw.githubusercontent.com/njmccorkle/Ubuntu/master/PostInstall/filebeat/logstash-forwarder.crt
	mkdir -p /etc/pki/tls/certs
	cp logstash-forwarder.crt /etc/pki/tls/certs/

	sudo systemctl restart filebeat
	sudo systemctl enable filebeat
 }
 
verify_root
verify_args "$@"
read -p "This will set the hostname to $1 and install all packages. Continue? Y/N" -n 1 -r
echo    # move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

set_hostname "$@"
install_system_packages
install_snmpd
install_filebeat
