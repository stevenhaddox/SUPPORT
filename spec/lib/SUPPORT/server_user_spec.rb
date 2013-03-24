require 'spec_helper'

describe "ServerUser" do
  before :each do
    @server_user = FactoryGirl.build(:server_user, :primary)
  end

  describe ".initialize" do
    it "should init with a server" do
      @server_user.server.role.should eql(SUPPORT::Server.new(@server_user.server.role).role)
    end

    it "should assign users for the server" do
      @server_user.users.count.should == 4
    end
  end

  describe ".all" do
    it "should return a collection of users" do
      @server_user.all.count.should == 4
      @server_user.all.map{|u| u.class}.uniq.should == [SUPPORT::User]
    end
  end

  describe ".find" do
    it "should return the user matching the role given" do
      app_user = @server_user.find('app')
      app_user.role.should == "app"
      app_user.username.should == "vagrant"
      app_user.password.should == "vagrant"

      root_user = @server_user.find(:root)
      root_user.role.should == "root"
      root_user.username.should == "root"
      root_user.password.should == "vagrant"
    end
  end

end
