# Workflow for SUPPORT server automation:

## Update yum / apt repos MANUALLY

1. sudo (yum|apt-get) update

## Copy SSH pub key to server

1. scp $HOME/<id_file>.pub app_user@server:/home/app_user/<id_file>.pub
2. cat /home/app_user/<id_file>.pub >> /home/app_user/authorized_users
3. rm /home/app_user/<id_file>.pub


## Test Capistrano Configuration

1. Run cap uname task
2. mkdir $HOME/src
3. Run cap upload test task

## Setup chef-solo

1. Determine if chef is installed
  * Yes:
    * exit with chef version printed out
  * No:
    * Upload stow src
    * Compile stow manually
    * mkdir -p ~/src/infrastructure/chef-from-source
    * Upload Ruby 1.9.3 source to ~/src/
    * Install Ruby 1.9.3 manually via stow
    * Upload bundler, chef, and dependencies to $SUPPORT/src/
    * Run capistrano rake task to compile Ruby from source
    * Run bundler install --local $SUPPORT/src/chef-11.x.gem
2. Setup stow
  * Run stow cookbook (should have no effect if ran manually before)
3.



### Sources:

[stow_src_url](http://git.savannah.gnu.org/cgit/stow.git/snapshot/stow-2.2.0.tar.gz)

[OpenJDK-64](http://www.java.net/download/jdk7u12/archive/b08/binaries/jdk-7u12-ea-bin-b08-linux-x64-03_jan_2013.tar.gz)
[OpenJDK-32](http://www.java.net/download/jdk7u12/archive/b08/binaries/jdk-7u12-ea-bin-b08-linux-i586-03_jan_2013.tar.gz)

    # Upload jdk-7u12-ea-bin-b08-linux-x64-03_jan_2013.tar.gz
    $ cd ${SRC}
    $ tar -xzvf jdk-7u12-ea-bin-b08-linux-x64-03_jan_2013.tar.gz
    $ mv jdk1.7.0_12 ${STOW}
    $ cd ${STOW}
    $ stow jdk1.7.0_12
    $ java -version
    #=> java version "1.7.0_12-ea"
    #=> Java(TM) SE Runtime Environment (build 1.7.0_12-ea-b08)
    #=> Java HotSpot(TM) 64-Bit Server VM (build 24.0-b28, mixed mode)

[Oracle JDK Download / License Page](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)

Direct download URLs after accepting the license:

* [JDK-64bit](http://download.oracle.com/otn-pub/java/jdk/7u17-b02/jdk-7u17-linux-x64.tar.gz)
* [JDK-32bit](http://download.oracle.com/otn-pub/java/jdk/7u17-b02/jdk-7u17-linux-i586.tar.gz)
* [JDK-64bit.rpm](http://download.oracle.com/otn-pub/java/jdk/7u17-b02/jdk-7u17-linux-x64.rpm)


