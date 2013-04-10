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

end
