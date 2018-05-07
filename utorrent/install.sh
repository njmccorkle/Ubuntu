#!/bin/bash
#create utorrent user with uid/gid that match user on FreeNAS server
groupadd -gid 1010 utorrent
adduser -uid 1010 -gid 1010 --system utorrent 
#??usermod -aG sudo utorrent


#change to utorrent user - this may not be needed
#??su - utorrent -s /bin/bash

#not necessary. using a system account
#download vimrc and save as ~/.vimrc 
#ssh
#download ssh stuff to ~/.ssh/.....


# start here

#setup shares
apt-get -y install cifs-utils
mkdir /mnt/media
chown utorrent /mnt/media
#?chmod 775 /mnt/media?
wget -O .smbcredentials -q https://raw.githubusercontent.com/njmccorkle/Ubuntu/master/utorrent/.smbcredentials.utorrent
chmod 600 .smbcredentials

cp /etc/fstab /etc/fstab.original
wget -O /etc/fstab -q https://raw.githubusercontent.com/njmccorkle/Ubuntu/master/utorrent/fstab.utorrent
mount -a

