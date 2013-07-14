# SUPPORT:

**S**etting **U**p & **P**rovisioning **P**ragmatic **O**SS **R**uby **T**echnologies

[![Build Status](https://travis-ci.org/stevenhaddox/SUPPORT.png?branch=master)](https://travis-ci.org/stevenhaddox/SUPPORT) [![Dependency Status](https://gemnasium.com/stevenhaddox/SUPPORT.png)](https://gemnasium.com/stevenhaddox/SUPPORT) [![Code Climate](https://codeclimate.com/github/stevenhaddox/SUPPORT.png)](https://codeclimate.com/github/stevenhaddox/SUPPORT)

## NOTE:

SUPPORT is using Readme Driven Development. The information that follows is the ultimate goals for SUPPORT, but most of it has not yet been implemented. BDD & TDD are being used. Simply run: `bundle exec rspec` to see what features have been implemented thus far within SUPPORT.

## About:

SUPPORT is a CLI gem that enables simple Capistrano enabled Berkshelf Chef cookbook deploys by packaging the source code to common OSS Ruby and Agile management projects and providing cookbooks that install those projects & packages from source (without sudo privileges when possible).
SUPPORT is only possible because of the amazing OSS tools that power it.

SUPPORT uses:

* [chef](http://www.opscode.com/chef/)
* [berkshelf](http://berkshelf.com/)
* Tutorials from [Atomic Object](http://atomicobject.com):
  * [Chef Solo with Capistrano](http://spin.atomicobject.com/2012/12/18/chef-solo-with-capistrano/)
  * [Chef Solo with Capistrano and Berkshelf](http://spin.atomicobject.com/2013/01/03/berks-simplifying-chef-solo-cookbook-management-with-berkshelf/)

SUPPORT provides packaging and deployment for the following projects:

#### Provisioning:

* [Chef Server](http://docs.opscode.com/#the-chef-server)

#### Git:

* [GitLab HQ](https://github.com/gitlabhq/gitlabhq)

#### Continuous Integration:

* [GitLab CI](https://github.com/gitlabhq/gitlab-ci)
* [Jenkins](http://jenkins-ci.org)
* [Travis CI](https://travis-ci.org)

#### Ruby:

* [Gem in a Box](https://github.com/cwninja/geminabox)
* [RVM::FW](https://github.com/stevenhaddox/rvm_fw)

#### Errors:

* [Errbit](https://github.com/errbit/errbit)

#### Logs:

* [Logstash](http://logstash.net)
* [Kibana](http://kibana.org)

#### E-Mail / SMTP:

* [Mailcatcher](http://mailcatcher.me)

#### Agile Project Management:

* [ChiliProject](https://www.chiliproject.org)
* [Fulcrum](https://github.com/malclocke/fulcrum)
* [Redmine](http://www.redmine.org)

#### Metrics:

* [FnordMetric](https://github.com/paulasmuth/fnordmetric)

#### Security:

* [Snorby](https://snorby.org)

## Usage:

SUPPORT allows you to setup a configuration file (`config/support_recipes.toml`) that specifies which tools you'd like to run on your SUPPORT server. To find out which OSS projects are available run:

    $ support available

To list the packages you've configured for your server run:

    $ support ready

To download the source code for all of the projects you've selected as well as their dependencies you simply run:

    $ support package

This will result in a file in your current directory named `support_drop.tgz`.

Copy this file to your internal LAN (this automatically includes the support gem and it's depdency gems).

From within your network where you'll be running your deploy you need to do a few things:

1. Setup ssh key-based authentication on your SUPPORT enabled server.
2. Create a Capistrano configuration in `config/deploy/support.rb` (you can use `config/deploy/support.rb.example` as a guideline).
3. Install the `SUPPORT` gem locally:

        $ bundle install --local

4. Prepare to deploy your SUPPORT drop. In order to do this you'll have to work through some issues as you try to run your deploy and make changes to your environment (hopefully these will be minimal as SUPPORT tries not to assume any more privileges than absolutely required). These custom commands that need to be run should be created in the `custom_commands.rb` (#TODO: Figure out the real name & location of this file) file so that they are easily repeatable. This file is automically processed at the beginning of each SUPPORT drop and allows you to ensure a consistent environment should your SUPPORT environment expand to additional servers in the future.
5. Deploy your customized SUPPORT drop to your SUPPORT server:

        $ support drop

6. Fix any configuration errors by adding the needed commands as described in step 4 and rerun step 5 until it's working properly.

## Notes

Chef configuration information in [/chef](chef).

Capistrano configuration information in [/config](config).

## Test Suite

### Default Vagrant Setup

In order to run the test suite you'll need to create a custom [config/support.toml](config/support.toml.example) file or use the following steps to configure your development environment to work with the expected defaults to access a running Vagrant VM with the example configuration file.

Download Vagrant's **insecure** private key:

```
$ wget https://raw.github.com/mitchellh/vagrant/master/keys/vagrant -O $HOME/.ssh/id_rsa.vagrant
```

Setup the `vagrant.vm` resolver & SSH configuration for default key, username, etc.:

```
# /etc/hosts
33.33.33.10 vagrant.vm # default vagrant IP
```

```
# $HOME/.ssh/config
Host vagrant.vm
  IdentityFile ~/.ssh/id_rsa.vagrant
  Hostname vagrant.vm
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  User vagrant
  LogLevel QUIET
```

Download the SUPPORT customized Vagrant box:

**Note**: Vagrant won't untar the SUPPORT box file currently, do the following
steps manually:

```bash
$ wget http://bit.ly/SUPPORT-x64 -O ~/.vagrant/boxes/vagrant-centos59-x86_64-SUPPORT.box
$ cd ~/.vagrant/boxes
$ mkdir vagrant-centos59-x86_64-SUPPORT
$ tar -xzvf vagrant-centos59-x86_64-SUPPORT.box -C vagrant-centos59-x86_64-SUPPORT/
$ vagrant box list
#=> vagrant-centos59-x86_64-SUPPORT
```

### Running the Tests

```bash
$ vagrant up
$ bundle install
$ bundle exec rake
```
