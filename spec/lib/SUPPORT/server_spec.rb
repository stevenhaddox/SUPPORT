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

  describe ".login" do
    it "should authenticate to the specified remote server" do
      pending
    end
  end

  describe ".setup" do
    it "should have access to the pubkey location" do
      SUPPORT.config["pubkey_path"].should == "$HOME/.ssh/id_dsa.pub"
    end

    it "should copy the pubkey to the remote server" do
      pending
    end
  end
end
