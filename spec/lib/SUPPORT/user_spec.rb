require 'spec_helper'

describe "User" do
  let(:user) { FactoryGirl.build(:user) }

  describe ".initialize" do
    it "should assign attributes" do
      user.role.should     == "install"
      user.username.should == "sysadmin"
      user.password.should == "vagrant"
      user.should be_enabled
    end
  end

  describe ".switched_from" do
    it "should assign & return the role for the assigned user" do
      from_user = FactoryGirl.build(:user)
      user = FactoryGirl.build(:user)
      user.switched_from = from_user.role
      user.switched_from.should == from_user.role
    end
  end

  describe ".switched_to?" do
    it "should return true if the user was not directly logged into" do
      server = FactoryGirl.build(:server)
      from_user = server.users.find(:root, :include_disabled => true)
      to_user   = server.users.enabled.last
      server.current_user = from_user
      server.switch_user to_user.role
      to_user.switched_to?.should == true
    end
  end

end
