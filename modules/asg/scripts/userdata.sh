#!/bin/bash


# Install httpd server
yum install httpd -y

# Enable service start on boot
systemctl enable httpd

# Prepare index file
cat <<EOT >> /var/www/html/index.html

<h1> Coalfire Web Servers </h1>

<h2> IP Address....: $(hostname -i) </h2>
<h2> Hostname......: $(hostname) </h2>
EOT

# Update index file permission
chmod 644 /var/www/html/index.html

# Restart httpd service
systemctl restart httpd
