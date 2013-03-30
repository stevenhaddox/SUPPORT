require 'spec_helper'

describe "Server" do
  before :each do
    @server = FactoryGirl.build(:server)
  end

  describe ".initialize" do
    it "should init attributes from config" do
      config_server           = SUPPORT.config["servers"]["primary"]
      @server.role.should     == "primary"
      @server.ip.should       == config_server["ip"]
      @server.port.should     == config_server["port"]
      @server.hostname.should == config_server["hostname"]
    end
  end

  describe ".users" do
    it "should return all server users" do
      server_users = SUPPORT::ServerUser.new({:role => @server.role})
      @server.users.all.map{|u| [u.role, u.username]}.should =~ server_users.all.map{|u| [u.role, u.username]}
    end
  end

  describe ".current_user" do
    it "should assign & access current_user" do
      @server.current_user = :app
      @server.current_user.should == @server.users.find('app')
      @server.current_user = :install
      @server.current_user.should == @server.users.find(:install)
    end
  end

  describe ".installer" do
    it "should return the user who will install system services" do
      @server.installer.username.should == SUPPORT::ServerUser.new({:role => @server.role}).find('install').username
    end
  end

  describe ".deployer" do
    it "should return the user who will deploy applications" do
      @server.deployer.username.should == SUPPORT::ServerUser.new({:role => @server.role}).find('app').username
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
