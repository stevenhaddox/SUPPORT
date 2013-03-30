require 'spec_helper'

describe "User" do
  before :each do
    @user = FactoryGirl.build(:user)
  end

  describe ".initialize" do
    it "should assign attributes" do
      @user.role.should     == "install"
      @user.username.should == "sysadmin"
      @user.password.should == "vagrant"
      @user.enabled.should  == true
    end
  end

end
