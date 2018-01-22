# Create Beats source list
echo "deb https://packages.elastic.co/beats/apt stable main" |  sudo tee -a /etc/apt/sources.list.d/beats.list

#Get Elasticsearch GPG key
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

#Update repos and install filebeat
apt-get update
apt-get install filebeat

#download and move filebeat configuration
wget https://raw.githubusercontent.com/njmccorkle/Ubuntu/master/PostInstall/filebeat.yml
cp filebeat.yml /etc/filebeat/filebeat.yml

sudo systemctl restart filebeat
sudo systemctl enable filebeat
