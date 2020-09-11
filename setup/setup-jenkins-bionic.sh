#! /usr/bin/bash
# bash script setup jenkins 

# Install Open JDK, Jenkins and Nginx
echo "Install Open JDK, Jenkins and Nginx"
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt install openjdk-8-jdk jenkins nginx -y

#starting and enabling at boot
echo "starting and enabling at boot"
sudo systemctl enable jenkins
sudo systemctl start jenkins
     
# add Jenkins web nginx config
echo "adding and symlinking config /etc/nginx/sites-available/jenkins"
sudo wget https://github.com/goodmeow/myscript/raw/master/ci/jenkins/jenkins -P /etc/nginx/sites-available/
sudo chmod 644 /etc/nginx/sites-available/jenkins
sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/

# Logs files arent created automatically fr0m ng1nx so we need to make one
echo "Logs files arent created automatically fr0m ng1nx so we need to make one"
sudo mkdir -p /var/log/nginx/jenkins 
sudo touch /var/log/nginx/jenkins/access.log 
sudo touch /var/log/nginx/jenkins/error.log
     
# IPTABLES allow 80
echo "if azure goto portal to enable 80 now assuming on gcp"
sudo iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT

echo "configure your IP on nginx and open browser to continue jenkins setup"
sudo iptables -L -n
