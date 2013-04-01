
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

stow_src_url: http://git.savannah.gnu.org/cgit/stow.git/snapshot/stow-2.2.0.tar.gz