require 'spec_helper'

describe "Server" do
  before :each do
    @server = SUPPORT::Server.new('primary')
  end

  describe ".initialize" do
    it "should init attributes from config" do
      config_server           = SUPPORT.config["servers"]["primary"]
      @server.ip.should       == config_server["ip"]
      @server.port.should     == config_server["port"]
      @server.hostname.should == config_server["hostname"]
    end
  end

  describe ".users" do
    it "should return a collection of users" do
      users = [['root','root'],['install','sysadmin'],['personal','steven'],['app','vagrant']]
      password = 'vagrant'
      @server.users.should == users.map {|u| SUPPORT::Server::User.new(u[0],u[1],password) }
    end
  end

  describe ".user" do
    it "should return the install user by default" do
      @server.user.should == SUPPORT::Server::User.new('install','sysadmin','vagrant')
    end

    it "should return the user matching the role given" do
      @server.user('app').should == SUPPORT::Server::User.new('app','vagrant','vagrant')
      @server.user(:root).should == SUPPORT::Server::User.new('root','root','vagrant')
    end
  end

  describe ".current_user" do
    it "should return the default user if not assigned" do
      @server.current_user.should == @server.user(:install)
    end

    it "should assign & access current_user" do
      @server.current_user= :app
      @server.current_user.should == @server.user(:app)
    end
  end

  describe ".exec" do
    it "should authenticate to the specified remote server" do
      @server.current_user= :app
      server_response = @server.exec{''}
      server_response.stdout.should == ""
      server_response.success.should == true
      server_response.exit_code.should == 0
    end

    it "should run a command block remotely on the server" do
      @server.current_user= :app
      server_response = @server.exec{'hostname'}
      server_response.stdout.should == "vagrant-c5-x86_64\n"
      server_response.success.should == true
      server_response.exit_code.should == 0
    end
  end

  describe ".eval_pubkey_path" do
    it "should have access to the pubkey location" do
      SUPPORT.config["pubkey_path"].should == "$HOME/.ssh/id_dsa.pub"
    end

    it "should eval the pubkey to expand the file's path" do
      @server.eval_pubkey_path.should == "#{`echo $HOME`.rstrip}"+"/.ssh/id_dsa.pub"
    end
  end

  describe ".scp" do
    it "should copy a local file to the server" do
      `rm /tmp/SUPPORT_tmp.txt`
      `touch /tmp/SUPPORT_tmp.txt`
      @server.current_user= :app
      server_response = @server.scp("/tmp/SUPPORT_tmp.txt")
      server_response.success.should == true
    end
  end

  describe ".scp_pubkey" do
    it "should copy the pubkey to the remote server" do
      @server.current_user = :app
      # backup existing authorized_keys
      @server.exec{"cp $HOME/.ssh/authorized_keys $HOME/.ssh/authorized_keys.bak"}
      # copy pubkey to server
      server_response = @server.exec{"cat $HOME/#{@server.current_user}/.ssh/authorized_keys"}
      server_response.stdout.should == ""
      # restore backed up authorized_keys
      @server.exec{"mv $HOME/.ssh/authorized_keys.bak $HOME/.ssh/authorized_keys"}
    end
  end
end
