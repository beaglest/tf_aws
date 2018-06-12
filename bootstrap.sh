#!/bin/bash
sudo yum update -y
sudo yum install -y httpd24 php70 php70-mysqlnd
sudo service httpd start
sudo chkconfig httpd on
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
echo "<html><h1>Hello</h1></html>" > /var/www/html/index.html
echo "<?php" >> /var/www/html/index.php
echo "\$username = \"${rds_uname}\";" >> /var/www/html/index.php
echo "\$password = \"${rds_pwd}\";" >> /var/www/html/index.php
echo "\$hostname = \"${rds_address}\";" >> /var/www/html/index.php
echo "\$dbname = \"${rds_dbname}\";" >> /var/www/html/index.php
echo "\$dbhandle = mysqli_connect(\$hostname, \$username, \$password) or die(\"Unable to connect to MySQL\");" >> /var/www/html/index.php
echo "echo \"Connected to MySQL using username - \$username, host - \$hostname<br>\";" >> /var/www/html/index.php
echo "\$selected = mysqli_select_db(\$dbhandle, \$dbname)   or die("Unable to connect to MySQL DB - check the database name and try again.");" 
echo "?>" >> /var/www/html/index.php
