#!/bin/bash
#
# This script does all mccorkle.co post install setup tasks.
# assumes that open-vm-tools, openssh-server, snmpd, build-essential, and ufw were installed during installation

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
        apt-get -y install openssh-server open-vm-tools vim apt-transport-https build-essential

        #ufw firewall
	apt-get -y install ufw
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow openssh
        ufw --force enable
}

install_snmpd () {
        echo "Installing snmpd"
        apt-get -y install snmpd
        wget -q https://raw.githubusercontent.com/njmccorkle/Ubuntu/master/PostInstall/files/snmpd.conf
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
	
	hostanme "$1"
 }
 
 setup_elastic_sources() {
 	# Create Beats source list
	#echo "deb https://packages.elastic.co/beats/apt stable main" > /etc/apt/sources.list.d/beats.list
	echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list

	#Get Elasticsearch GPG key
	wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
	
	apt-get update
	
	#move private key
	wget -q https://raw.githubusercontent.com/njmccorkle/Ubuntu/master/PostInstall/files/logstash-public.crt
	mkdir -p /etc/pki/tls/certs
	cp logstash-public.crt /etc/pki/tls/certs/
 }
 
 install_filebeat() {
 	echo "Installing Filebeat"
	
	#Install filebeat
	apt-get -y install filebeat

	#download and move filebeat configuration
	wget -q https://raw.githubusercontent.com/njmccorkle/Ubuntu/master/PostInstall/files/filebeat.yml
	cp filebeat.yml /etc/filebeat/filebeat.yml

	(cd /etc/filebeat/; sudo /usr/share/filebeat/bin/filebeat modules enable system)
	#restart and enable services
	systemctl daemon-reload
	systemctl enable filebeat
	systemctl restart filebeat
 }
 
 install_packetbeat() {
 	echo "Installing Packetbeat"
	
	#Install Packetbeat
	apt-get -y install packetbeat
	
	#download and move packetbeat configuration
	wget -q https://raw.githubusercontent.com/njmccorkle/Ubuntu/master/PostInstall/files/packetbeat.yml
	cp packetbeat.yml /etc/packetbeat/packetbeat.yml
	
	#restart and enable services
	systemctl daemon-reload
	systemctl enable packetbeat
	systemctl start packetbeat
 }
 
  install_metricbeat() {
 	echo "Installing Metricbeat"
	
	#Install Metricbeat
	apt-get -y install metricbeat
	
	#download and move packetbeat configuration
	wget -q https://raw.githubusercontent.com/njmccorkle/Ubuntu/master/PostInstall/files/metricbeat.yml
	cp metricbeat.yml /etc/metricbeat/metricbeat.yml
	
	#restart and enable services
	systemctl daemon-reload
	systemctl enable metricbeat
	systemctl start metricbeat
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
setup_elastic_sources
install_filebeat
install_packetbeat
install_metricbeat
