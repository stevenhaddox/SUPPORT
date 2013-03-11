require 'spec_helper'

describe "Server" do
  before :each do
    @server = SUPPORT::Server.new('primary')
  end

  describe ".initialize" do
    it "should init attributes from config" do
      config_server = SUPPORT.config["servers"]["primary"]
      @server.ip.should == config_server["ip"]
      @server.port.should == config_server["port"]
      @server.user.should == config_server["user"]
      @server.password = config_server["password"]
      @server.hostname = config_server["hostname"]
    end
  end

  describe ".exec" do
    it "should authenticate to the specified remote server" do
      server_response = @server.exec{''}
      server_response.stdout.should == ""
      server_response.success.should == true
      server_response.exit_code.should == 0
    end

    it "should run a command block remotely on the server" do
      server_response = @server.exec{'hostname'}
      server_response.stdout.should == "vagrant-c5-x86_64\n"
      server_response.success.should == true
      server_response.exit_code.should == 0
    end
  end

  describe ".scp" do
    it "should copy a local file to the server" do
      `rm /tmp/SUPPORT_tmp.txt`
      `touch /tmp/SUPPORT_tmp.txt`
      server_response = @server.scp("/tmp/SUPPORT_tmp.txt")
      server_response.success.should == true
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

  describe ".scp_pubkey" do
    it "should copy the pubkey to the remote server" do
      @server.scp_pubkey
      server_response = @server.exec{"cat /home/#{@server.user}/.ssh/authorized_keys"}
      server_response.stdout.should include(`cat #{@server.eval_pubkey_path}`)
    end
  end
end
