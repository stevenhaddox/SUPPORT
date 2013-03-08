require 'spec_helper'

describe "Server" do
  before :each do
    @server = SUPPORT::Server.new('primary')
  end

  describe ".login" do
    it "should authenticate to the specified remote server" do
      config_server = SUPPORT.config["servers"]["primary"]
      @server.user.should == config_server["user"]
      @server.password = config_server["password"]
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
