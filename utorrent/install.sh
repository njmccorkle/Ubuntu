#!/bin/bash
#create utorrent user with uid/gid that match user on FreeNAS server
groupadd -gid 1010 utorrent
adduser -uid 1010 -gid 1010 --system utorrent 

#change to utorrent user
su - utorrent -s /bin/bash

#not necessary. using a system account
#download vimrc and save as ~/.vimrc 
#ssh
download ssh stuff to ~/.ssh/.....


# start here

#setup shares
apt-get install cifs-utils
mkdir /mnt/media
chown utorrent /mnt/media
#?chmod 775 /mnt/media?
download smbcredentials and save as ~/.smbcredentials
chmod 600 .smbcredentials
download fstab and copy to /etc/
mount -a

