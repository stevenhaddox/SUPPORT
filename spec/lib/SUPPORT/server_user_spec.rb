require 'spec_helper'

describe SUPPORT::ServerUser do
  let(:server_user) { FactoryGirl.build(:server_user, :primary) }

  describe ".initialize" do
    it "should instantiate with valid params" do
      SUPPORT::ServerUser.new({:role => "primary"}).class.should == SUPPORT::ServerUser
    end

    it "should not be valid without a server role" do
      lambda { SUPPORT::ServerUser.new({}) }.should raise_error(KeyError)
    end

    it "should assign users" do
      server_user.users.count.should > 0
    end
  end

  describe ".all" do
    it "should return a collection of all users" do
      server_user.all.count.should == 4
      server_user.all.map{|u| u.class}.uniq.should == [SUPPORT::User]
    end
  end

  describe ".find" do
    it "should return the user matching the role given" do
      user = server_user.find('app')
      user.role.should     == "app"
      user.username.should == "vagrant"
      user.password.should == "vagrant"
      user.enabled.should  == true
    end

    it "should return the user found when given a role as a symbol" do
      user = server_user.find(:install)
      user.role.should     == "install"
      user.username.should == "sysadmin"
      user.password.should == "vagrant"
      user.enabled.should  == true
    end

    it "should not return a user that is not enabled" do
      user = server_user.find(:root)
      user.should == nil
    end

    it "should return a disabled user when sent the param ignore_disabled" do
      user = server_user.find(:root, {:include_disabled => true})
      user.role.should     == "root"
      user.username.should == "root"
      user.password.should == "vagrant"
      user.enabled.should  == false
    end
  end

  describe ".find_by_role_priority" do
    it "should return the first enabled user matching the order of roles given" do
      prioritized_roles = %w(root personal install app)
      user = server_user.find_by_role_priority prioritized_roles
      user.role.should     == "install"
      user.username.should == "sysadmin"
      user.enabled.should  == true
    end
  end

end
