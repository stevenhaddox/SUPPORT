# How to Install Strands From Scratch

Unless specifically instructed to run a set of commands as `root`, all groups of commands are run as the application user (`<app_user>`) you'll create in this tutorial.

What this tutorial covers:

* Setting up a MySQL & Redis database server
* Setting up Apache with Passenger & RVM integration
* Setting up an application user and group
* Configuring permissions to remove any need for `root` or `sudo` access in the future

## Variables

Throughout this guide you'll come across a few variables so that this guide can be used for more than one Rails application / server setup. Please use the following values for these variables:

    <deploy_path>:       /var/www
    <app_name>:          strands
    <app_version>:       Version of the application or Capistrano timestamp
    <app_user>:          ruby
    <app_user_pwd>:      Password for the <app_user>
    <app_group>:         ruby
    <mysql_root_pwd>:    The MySQL root password
    <mysql_conf_file>:   The MySQL configuration file for the local MySQL instance
    <hostname>:          Application server hostname (e.g., <app_name>)
    <fqdn>:              Application server's fully qualified domain name (e.g., app-url.com)
    <server_ip>:         Application server's IP address
    <your_user>:         Your username on the application server
    <team_usernames>:    Usernames of all team members on the application server
    <gem_server_url>:    Internal gem server URL (optional)
    <country_code>:      Your 2 character country code
    <organization_name>: Your organization's official name
    <organization_unit>: Your organization's subdivision, etc.
    <ca_cert_file_name>: Filename of your Certificate Authority file
    <intranet_hostname>: The intranet's FQDN

## Initial Steps

To setup the essentials we'll start out as `root`:

    $ su -
    # Enter the root password when prompted

Ensure that SELinux is disabled. Modify the `/etc/selinux/config` file to ensure the following parameter is set as follows:

    # /etc/selinux/config
    #SELINUX=enforcing
    SELINUX=permissive

Restart the server before proceeding if you needed to modify the value of the SELINUX parameter. Once the server has rebooted, run the following command to ensure SELinux has been put into a permissive state:

    $ sestatus
    # The following parameters should be shown in the status:
    #   SELinux status: enabled
    #   Current mode:   permissive

Update yum:

    $ yum update

Install essential yum packages:

    $ yum install make gcc-c++ wget telnet

Create a folder we can copy source files to later as needed:

    $ mkdir ~/src
    $ mkdir /tmp/<app_name>

Insert the application CD/DVD into the system, and mount the drive:

    $ mount /dev/cdrom /media

Copy the `<app_name>` source files from CD/DVD to the local system:

    $ cp /media/<app_name>-<app_version>.tgz /tmp/<app_name>/
    $ cd /tmp/<app_name>
    $ tar -xzvf <app_name>-<app_version>.tgz

Unmount the drive now that all files have been copied:

    $ umount /media

## Setup Passenger & RVM Package Dependencies

**NOTE:** All steps in this section should be run via `sudo` or as the `root` user.

    # The following are absolutely essential
    $ yum install httpd httpd-devel mod_ssl
    $ yum install curl-devel apr-devel apr-util-devel openssl-devel
    $ yum install git
    $ yum install bzip2 readline readline-devel
    $ yum install libtool libxml2 libxml2-devel libxslt libxslt-devel

    # Useful for remote connections / editing
    $ yum install vim screen tmux

    # The following are non-critical, but improve Ruby performance if installed
    $ yum install patch zlib zlib-devel libffi-devel libyaml-devel
    $ yum install iconv-devel

    # **NOTE:** The following are critical packages to allow <app_name> to run
    # You'll need Ruby 1.8.7, 1.9.2, or 1.9.3
    $ yum install ruby 

    # We'll also need rubygems 1.3.7, or 1.8.5+
    $ yum install rubygems

## Setup the MySQL Database

**NOTE:** All steps in this section should be run via `sudo` or as the `root` user.

Install MySQL from yum:

    $ yum install mysql-devel mysql
    $ yum install mysql-server 

Copy the customized configuration file for `/etc/my.cnf`:

    # NOTE: Inspect and choose the my.cnf file that makes sense based on the hardware
    #       configuration of your system. Contact an administrator for guidance if you
    #       are unsure which my.cnf file makes sense for your needs.
    $ cp /tmp/<app_name>/<app_name>-<app_version>/vendor/src/confs/<mysql_conf_file>.cnf /etc/my.cnf
    # enter yes when prompted to overwrite the existing my.cnf file

Now that MySQL is ready we need to make sure it starts on server reboot/startup:

    $ chkconfig mysqld on

And now we'll start it for our current session:

    $ service mysqld start

Let's secure MySQL by running the following script:

    $ mysql_secure_installation
    Enter current password for root (enter for none): (Press enter)
    Set root password? [Y/n]: Y
    New password: <mysql_root_pwd>
    Re-enter password: <mysql_root_pwd>
    Remove anonymous users? [Y/n]: Y
    Disallow root login remotely? [Y/n]: Y
    Remove test database and access to it? [Y/n]: Y
    Reload privilege tables now? [Y/n]: Y

Verify you can connect to MySQL:

    $ mysql -u root -p
    # Enter the MySQL root password entered previously when prompted
    # Exit mysql once verified that the root user can login with the given password
    mysql> exit

## Setup the Redis Database

**NOTE:** All steps in this section should be run via `sudo` or as the `root` user.

Copy & extract the redis-stable (2.4) source code from the extracted `<app_name>` CD:

    # Copy the source files
    $ cp /tmp/<app_name>/<app_name>-<app_version>/vendor/src/redis-2.4.tar.gz ~/src/
    $ cp /tmp/<app_name>/<app_name>-<app_version>/vendor/src/confs/redis.conf ~/src/

    # Install Redis from source
    $ cd ~/src
    $ tar -xzvf redis-2.4.tar.gz
    $ mv redis-stable redis-2.4
    $ cd redis-2.4
    $ make
    $ make install
    $ mkdir /etc/redis
    $ cp ~/src/redis.conf /etc/redis/6379.conf
    $ mkdir -p /var/redis/6379
    $ cp /tmp/<app_name>/<app_name>-<app_version>/vendor/src/confs/redis_init_script /etc/init.d/redis

Setup Redis to start on system reboot/startup:

    $ chmod 755 /etc/init.d/redis_init_script
    $ chkconfig redis on

Now start Redis for our current session:

    $ /etc/init.d/redis_6379 start > /dev/null 2>&1 &

Verify the connection to Redis works:

    $ redis-cli ping
    # You should see:
    > PONG

## Generate Server SSL Certificates

**NOTE:** All steps in this section (both self-signed certificates & CA PKI certificates) should be run via `sudo` or as the `root` user.

There are two ways to do this section, either via `go pki` or with self-signed certificates. The `go pki` method is preferred, but if you need this server **immediately** and can't wait a few days then follow the self-signed certificates route.

### Self-Signed Certificates

    $ cd /etc/pki/tls/
    $ openssl req -new -x509 -nodes -out certs/<fqdn>.crt -keyout private/<fqdn>.key

Provide the following information about your certificate when prompted:

    Country Name (2 letter code) [XX]: <country_code>
    State or Province Name (full name) []: .
    Locality Name (eg, city) [Default City]: .
    Organization Name (eg, company) [Default Copmany Ltd]: <organization_name>
    Organizational Unit Name (eg, section) []: <organization_unit>
    Common Name (eg, your name or your server's hostname) []: <fqdn>
    Email Address []: .

Let's symlink to the same file we'd have used if we'd done the normal CSR method:

    $ ln -s /etc/pki/tls/private/<fqdn>.key /etc/pki/tls/private/<fqdn>.nopass.key

Your certificate file paths for configurations will be:

    /etc/pki/tls/certs/<fqdn>.crt
    /etc/pki/tls/private/<fqdn>.nopass.key

### CA PKI Certificates

Start by generating your CSR by following the [Server PKI Steps](https://wiki.<intranet_hostname>/wiki/Server_PKI_Setup#Generating_the_certificate_request).

Once you've completed those steps, do the following:

    $ cd /etc/pki/tls/private/
    $ openssl genrsa -des3 -out <fqdn>.key 2048
    $ openssl req -new -key /etc/pki/tls/private/<fqdn>.key -out <fqdn>.csr

Provide the following information about your certificate when prompted:

    Country Name (2 letter code) [XX]: <country_code>
    State or Province Name (full name) []: .
    Locality Name (eg, city) [Default City]: .
    Organization Name (eg, company) [Default Copmany Ltd]: <organization_name>
    Organizational Unit Name (eg, section) []: <organization_unit>
    Common Name (eg, your name or your server's hostname) []: <fqdn>
    Email Address []: .

    Please enter the following 'extra' attributes
    to be sent with your certificate request
    #NOTE: Remember this password!
    A challenge password []:
    An optional company name []:

    # Use the password above to create a non-password version
    $ openssl rsa -in /etc/pki/tls/private/<fqdn>.key -out /etc/pki/tls/private/<fqdn>.nopass.key

Once your CSR is completed follow the last portion on [submitting your CSR](https://wiki.<intranet_hostname>/wiki/Server_PKI_Setup#Submitting_the_request_and_getting_results) to the PKI office.

## Create an Application User & Group, Grant Group Permissions for Apache & Certificates

**NOTE:** All steps in this section should be run via `sudo` or as the `root` user.

    # Create application user & application group
    $ groupadd <app_group>
    $ useradd -g <app_group> -G www-data -m <app_user>

    # Set up the <app_user> environment variables
    $ echo "export RAILS_ENV=production" >> ~<app_user>/.bash_profile

    # Add your username and any additional usernames to the application group
    $ usermod -a -G <app_group> <your_user> <team_usernames>

    # <app_name> mounted files permissions
    $ chown -R <app_user>:<app_group> /tmp/<app_name>

    # Apache permissions
    $ chown -R root:<app_group> /etc/httpd /var/log/httpd
    $ chmod 775 /etc/httpd /etc/httpd/conf /etc/httpd/conf.d /var/log/httpd
    $ chmod -R 664 /etc/httpd/conf/* /etc/httpd/conf.d/*

    # Certificate permissions
    $ chown -R <app_user>:<app_group> /etc/pki/tls/certs /etc/pki/tls/private
    $ chmod 775 /etc/pki/tls/certs
    $ chmod 664 /etc/pki/tls/certs/*.crt /etc/pki/tls/certs/Makefile
    $ chmod 600 /etc/pki/tls/private/*.key /etc/pki/tls/private/*.csr
    $ chmod 775 /etc/pki/tls/certs/make-dummy-cert

    # Create a PEM formatted certificate (for HTTParty and other tools)
    $ openssl pkcs12 -export -in /etc/pki/tls/certs/<fqdn>.crt -inkey /etc/pki/tls/private/<fqdn>.nopass.key -out /etc/pki/tls/certs/<fqdn>.p12
    # press enter without typing characters when prompted for a password (no password)

    $ openssl pkcs12 -in /etc/pki/tls/certs/<fqdn>.p12 -nodes -out /etc/pki/tls/certs/<fqdn>.pem
    # press enter without typing characters when prompted for a password (no password)

Next we'll need to modify the folder permissions:

    $ mkdir -p <deploy_path>/<app_name>
    $ chmod 775 <deploy_path>/<app_name>
    $ chown <app_user>:<app_group> <deploy_path>/<app_name>

## Grant `sudo` Privileges to <app_group> Users

**NOTE:** All steps in this section should be run via `sudo` or as the `root` user.

In order to ensure you can restart critical services if sudo privileges should be removed from your account in the future you'll need to grant users of your group permission to run certain commands via `sudo`.

    $ visudo
    # Append the following line to the bottom of the file
    %<app_group> ALL=NOPASSWD: /sbin/service

Write and quit the sudoers file.

## Enable key-based Authentication for SSH

We don't enable password based access to accounts, so you'll need to append your personal key's pub file to the `<app_user>`'s authorized keys file. Use the root user to upload your file to the /tmp folder, and then append it to the authorized key file as follows:

    # From your **LOCAL** computer:
    $ scp ~/.ssh/id_rsa.pub root@<server_ip>:/tmp/id_rsa.<your_user>.pub

    # From the application server (as root):
    $ mkdir ~<app_user>/.ssh
    $ cat /tmp/id_rsa.<your_user>.pub >> ~<app_user>/.ssh/authorized_keys

Be sure to double check the SSH folder permissions are as follows for the `<app_user>` user:

    $ chmod 700 ~<app_user>/.ssh
    $ chmod 600 ~<app_user>/.ssh/authorized_keys
    $ chown -R <app_user>:<app_group> ~<app_user>/.ssh

Ensure that the `/etc/ssh/sshd_config` file has the following parameters set - you must access this via the `root` user or the `sudo` command:

    # /etc/ssh/sshd_config
    PubkeyAuthentication yes
    PasswordAuthentication yes
    PermitEmptyPasswords no
    PermitRootLogin no

Restart the SSH service:

    $ /etc/init.d/sshd restart

You should now be able to login to the `<app_name>` server as the `<app_user>` account without having to enter a password. 

**NOTE:** From now on if you need to login to the `root` user account you will have to login to the server as the `<app_user>` and then run:

    # To become root from the <app_user> account run:
    $ su -
    # Enter root password

**NOTE:** If you do not have or do not wish to use key-based logins, or if you wish to allow password-based logins as an alternate mechanism for access to the application server, grant the `<app_user>` user a password using the following commands:

    # As root or via sudo on the new server (<fqdn>):
    $ passwd <app_user>
    Changing password for user <app_user>
    New password: <app_user_pwd>
    Retype new password: <app_user_pwd>
    passwd: all authentication tokens updated successfully.

## Setup RVM::FW (Locally)

Next we'll setup our specific version of Ruby within the `<app_user>` home directory to avoid any system-wide conflicts. We'll start by setting up `RVM::FW` which will allow us to host specific Ruby installation files on the local system. We'll need the system Ruby version (1.8.7, 1.9.2, or 1.9.3) to run `RVM::FW` which is why we installed it earlier.

**NOTE:** All steps in this section should be run via `sudo` or as the `root` user.

    $ cp -r /tmp/<app_name>/<app_name>-<app_version>/vendor/src/rvm_fw ~/src/rvm_fw
    $ cd ~/src/rvm_fw
    $ gem install ./vendor/bundler-1.1.3.gem
    $ bundle install --local --without development test
    $ cd ~

    # Create Capistrano folder infrastructure
    $ mkdir -p <deploy_path>/rvm_fw/releases <deploy_path>/rvm_fw/shared/system <deploy_path>/rvm_fw/shared/log <deploy_path>/rvm_fw/shared/pids
    $ mv ~/src/rvm_fw <deploy_path>/rvm_fw/releases/20120503000000
    $ ln -s <deploy_path>/rvm_fw/releases/20120503000000 <deploy_path>/rvm_fw/current

    # Make RVM::FW application accessible to <app_user>
    $ chown -R root:<app_user> <deploy_path>/rvm_fw
    $ cd <deploy_path>/rvm_fw/current

    # Now we need to start RVM::FW in background mode (silenced)
    $ bundle exec rackup -p 80 > /dev/null 2>&1 &

## Install RVM

**NOTE:** Unless specified otherwise, all commands that follow are as the `<app_user>`

Now that `RVM::FW` is running on our local server (on the default HTTP port 80) it's time to verify that we can connect to it and setup Ruby for our `<app_user>`. You'll probably want to open up a different terminal for this, but since `RVM::FW` is running in background mode you can use the same terminal if needed.

    $ curl localhost
    # You should see HTML output

    $ curl localhost/db
    # You should see plain text with Ruby & package URLs

Installing `RVM` is only a few commands:

    $ bash < <( curl http://localhost/releases/rvm-install-latest )
    $ source ~/.bash_profile

    # Verify RVM installed:
    $ rvm -v
    # You should see a version corresponding to the currently-installed RVM

    # Configure RVM to use RVM::FW:
    $ wget http://localhost/db -O ~/.rvm/user/db
    $ rvm reload

## Install Ruby (via RVM)

    $ rvm install ruby-1.9.2-p290

    # Update gem sources
    $ gem sources -r http://rubygems.org/

    # Only do this next step if you have an internal gem server
    $ gem sources -a <gem_server_url>

## Installing Bundler

    $ rvm use 1.9.2-p290@global --default
    $ gem install <deploy_path>/rvm_fw/current/vendor/bundler-1.1.3.gem

## Install Passenger

    $ rvm gemset create passenger3

    $ cd /tmp/<app_name>/<app_name>-<app_version>/vendor/cache/
    # When asked to trust the .rvmrc file, type 'n'

    $ rvm use 1.9.2-p290@passenger3
    $ gem install passenger-3.0.12.gem
    $ passenger-install-apache2-module

Copy the configuration setting lines from the `passenger-install-apache2-module` command output into the file `/etc/httpd/conf.d/passenger.conf`. It should look similar to the contents of the file referenced below, but will not be exact. Be sure your file matches your output **exactly** for Passenger to work properly.

    $ cp /tmp/<app_name>/<app_name>-<app_version>/vendor/src/confs/passenger.conf /etc/httpd/conf.d/passenger.conf
    # Modify the file to replace all variables with values at the beginning of this guide
    # Ensure that it matches the output from the passenger-install-apache2-module!

Now we need to edit the `<app_user>` user's `.rvmrc` file to support gemset switching automatically (for Passenger 3):

    $ cp /tmp/<app_name>/<app_name>-<app_version>/vendor/src/confs/.rvmrc ~<app_user>/.rvmrc
    # Modify the file to replace all variables with values at the beginning of this guide

Reload RVM for the changes to be recognized:

    $ rvm reload
    # A message may appear corresponding to the <app_name> gemset not existing - you can safely ignore this

Modify user home folder permissons to allow system access to Passenger:

    $ chmod 755 ~<app_user>

## Configure Apache with SSL

Create a folder for Apache configuration files that can created by our application user. Note, we are still the application user to ensure correct permissions:

    $ mkdir /etc/httpd/vhost.d
    $ echo "Include vhost.d/*.conf" >> /etc/httpd/conf/httpd.conf

We also need to update the `ssl.conf` configuration to work for our setup:

    # Make a backup of the file before editing:
    $ mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak
    $ cp /tmp/<app_name>/<app_name>-<app_version>/vendor/src/confs/ssl.conf /etc/httpd/conf.d/ssl.conf

Ensure that the `/etc/httpd/conf/httpd.conf` file has the following parameter set:

    # /etc/httpd/conf/httpd.conf
    ServerName <fqdn>

Once the SSL and HTTP configurations for Apache have been updated, restart the Apache services to ensure the changes take effect:

    # Ensure rackup is not running on port 80, and kill the process if it is (this should be done as root or via sudo)
    $ ps -ef | grep [r]ackup
    # If the rackup process is running, kill it by replacing <pid> below with the process ID
    # This will be the number in the column immediately following the `root` username column
    $ kill -9 <pid>

    # Restart Apache (as the <app_user>)
    $ sudo service httpd restart

Setup Apache to start when the server boots:

    # As root or via sudo
    $ chkconfig httpd on
    # Make log files readable by all
    $ chmod -R 664 /var/log/httpd/*

## Application Setup

### RVM::FW Setup

    # Create the RVM:FW gemset
    $ rvm gemset create rvm_fw
    $ cd <deploy_path>/rvm_fw/current
    $ bundle install --local

    # Configure RVM::FW to run on port 80 via Apache
    $ cp /tmp/<app_name>/<app_name>-<app_version>/vendor/src/confs/rvm_fw/vhost.conf /etc/httpd/vhost.d/rvm_fw.conf
    # Modify the file to replace all variables with values at the beginning of this guide

    # Setup RVM::FW to work with Passenger & RVM (as the root user or via sudo)
    $ cp /tmp/<app_name>/<app_name>-<app_version>/config/setup_load_paths.rb <deploy_path>/rvm_fw/shared/system/setup_load_paths.rb
    $ ln -s <deploy_path>/rvm_fw/shared/system/setup_load_paths.rb <deploy_path>/rvm_fw/current/config/setup_load_paths.rb

    # Setup RVM to trust the .rvmrc
    $ rvm rvmrc trust <deploy_path>/rvm_fw/current

    # Restart Apache
    $ sudo service httpd restart

### Application Setup

Next we'll setup our application. Create the database access permissions.

    # Create the database.yml file from the example file (Capistrano compatible)
    $ cp /tmp/<app_name>/<app_name>-<app_version>/config/database.yml.example /tmp/<app_name>/<app_name>-<app_version>/config/database.yml
    # Modify the file to replace variables with expected DB username/password information

Next, setup the application database per the previously-specified `database.yml` file.

    # Create the <app_user> user in MySQL with proper permissions to the production
    # application database using the username/password from the database.yml file:
    $ mysql -u root -p
    # (Enter password when prompted)
    mysql> CREATE DATABASE <app_name>;
    mysql> GRANT ALL PRIVILEGES ON <app_name>.* TO '<app_name>'@'localhost' IDENTIFIED BY '<app_user_pwd>' WITH GRANT OPTION;
    mysql> exit

Next, we'll setup the application itself.

    # Create the <app_name> gemset
    $ rvm gemset create <app_name>

    # Navigate to the application source folder
    $ cd /tmp/<app_name>/<app_name>-<app_version>

    # Configure bundler packages
    $ bundle install --path .bundle --local --without development test

    # Set up the directories required for Capistrano
    $ bundle exec cap local deploy:setup
    # Enter the <app_user> user's password when prompted if not using key-based authentication for SSH

    # Copy the database file to it's respective location
    $ cp config/database.yml <deploy_path>/<app_name>/shared/system/

    # Deploy the <app_name> application using Capistrano
    $ bundle exec cap local deploy:cold
    # Enter the <app_user> user's password when prompted if not using key-based authentication for SSH
    # Note: You may see an "err" appear corresponding to a Rake task deprecation - this is normal and
    #       can be safely ignored.

    # Setup RVM to trust the .rvmrc
    $ rvm rvmrc trust <deploy_path>/<app_name>/current

    # Load the data into the database
    $ cd <deploy_path>/<app_name>/current
    $ bundle exec rake db:fixtures:load

Now we'll create symlinks to the Apache log folders within our application log folder:

    $ cd <deploy_path>/<app_name>/shared/log
    $ ln -s /var/log/httpd/access_log
    $ ln -s /var/log/httpd/error_log
    $ ln -s /var/log/httpd/ssl_request_log
    $ ln -s /var/log/httpd/ssl_error_log

Now you can tail output from `<app_name>` by simply running:

    $ cd <deploy_path>/<app_name>/current
    $ tail -f log/*

Next we'll create a custom configuration file for our application as well as configure Apache to serve our application over SSL via port 443:

    # Let's add our primary application to run over SSL on port 443 via Apache
    $ cp /tmp/<app_name>/<app_name>-<app_version>/vendor/src/confs/vhost.conf /etc/httpd/vhost.d/<app_name>.conf
    # Modify the file to replace all variables with values at the beginning of this guide

    # **NOTE:** If using CA certificates or if you have self-signed certificates through a self-generated CA, ensure the following parameters are set in the file:
    # /etc/httpd/vhost.d/<app_name>.conf
    SSLCACertificateFile /etc/pki/tls/certs/<ca_cert_file_name>.crt
    SSLVerifyClient require

    # Restart Apache (as the <app_user>)
    $ sudo service httpd restart

## Cleanup

Now that we've completed our setup we need to delete those original source files we copied over.

    # As the root user or via sudo:
    $ rm -rf /tmp/<app_name>

    # If you uploaded your public certificate for <app_user> ssh login:
    $ rm -f /tmp/id_rsa.<your_user>.pub
