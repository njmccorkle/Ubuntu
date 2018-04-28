mkuser utorrent uid 1010 gid 1010

change to utorrent user

download vimrc and save as ~/.vimrc

#ssh
download ssh stuff to ~/.ssh/.....

#setup shares
apt-get install cifs-utils
mkdir /mnt/media
chown utorrent /mnt/media
#?chmod 775 /mnt/media?
download smbcredentials and save as ~/.smbcredentials
chmod 600 .smbcredentials
download fstab and copy to /etc/
mount -a

