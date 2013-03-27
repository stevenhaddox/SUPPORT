require 'spec_helper'

describe "ServerUser" do
  before :each do
    @server_user = FactoryGirl.build(:server_user, :primary)
  end

  describe ".initialize" do
    it "should instantiate with valid params" do
      SUPPORT::ServerUser.new({:role => "primary"}).class.should == SUPPORT::ServerUser
    end

    it "should not be valid without a server role" do
      lambda { SUPPORT::ServerUser.new({}) }.should raise_error(KeyError)
    end

    it "should assign users" do
      @server_user.users.count.should > 0
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
      user = @server_user.find('app')
      user.role.should == "app"
      user.username.should == "vagrant"
      user.password.should == "vagrant"
    end

    it "should return the user found when given a role as a symbole" do
      user = @server_user.find(:root)
      user.role.should == "root"
      user.username.should == "root"
      user.password.should == "vagrant"
    end
  end

end
