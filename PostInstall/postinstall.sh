#!/bin/bash
#
# This script does all mccorkle.co post install setup tasks.

verify_root() {
    # Verify running as root:
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

install_system_packages() {
    apt-get -y update
    # Base packages
    apt install -y open_ss
    # Data sources dependencies:
    apt install -y libffi-dev libssl-dev libmysqlclient-dev libpq-dev freetds-dev libsasl2-dev
    # SAML dependency
    apt install -y xmlsec1
    # Storage servers
    apt install -y postgresql redis-server
    apt install -y supervisor
}

verify_root
