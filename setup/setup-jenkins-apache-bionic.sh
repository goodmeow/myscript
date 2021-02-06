#! /usr/bin/bash
# bash script setup jenkins 

# Install Open JDK, Jenkins and Apache
echo "Install Open JDK, Jenkins and Apache"
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt install openjdk-8-jdk jenkins apache2 -y

# then start botj apache and jenkins
echo "starting and enabling at boot"
sudo systemctl start apache2
sudo systemctl start jenkins

# add Jenkins web apache2 config
echo "adding and symlinking config /etc/apache2/sites-available/jenkins"
sudo wget https://github.com/goodmeow/myscript/raw/master/ci/jenkins/jenkins.conf -P /etc/apache2/sites-available/
sudo chmod 644 /etc/apache2/sites-available/jenkins.conf

# a2enmod
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2ensite jenkins
sudo systemctl restart apache2
sudo systemctl restart jenkins

# IPTABLES allow 80
echo "if azure goto portal to enable 80 now assuming on gcp"
sudo iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT

echo "configure your IP on nginx and open browser to continue jenkins setup"
sudo iptables -L -n
