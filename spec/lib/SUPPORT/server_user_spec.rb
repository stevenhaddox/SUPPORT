require 'spec_helper'

module SUPPORT
  describe ServerUser do
    let(:server_user) { FactoryGirl.build(:server_user, :primary) }
  
    describe ".initialize" do
      context "valid params" do
        let(:params) do 
          {:role => "primary"}
        end 

        it "should instantiate with valid params" do
          described_class.new(params).class.should == SUPPORT::ServerUser
        end
      end
 
      context "invalid params" do 
        let(:params) do
          Hash.new
        end

        it "should not be valid without a server role" do
          lambda { described_class.new(params) }.should raise_error(KeyError)
        end
      end
  
      it "should assign users" do
        server_user.users.count.should > 0
      end
    end
  
    describe ".all" do
      it "should return a collection of all users" do
        server_user.all.count.should == 4
        server_user.all.map(&:class).uniq.should == [SUPPORT::User]
      end
    end
  
    describe ".find" do
      it "should return the user matching the role given" do
        user = server_user.find('app')
        user.role.should     == "app"
        user.username.should == "vagrant"
        user.password.should == "vagrant"
        user.should be_enabled
      end
  
      it "should return the user found when given a role as a symbol" do
        user = server_user.find(:install)
        user.role.should     == "install"
        user.username.should == "sysadmin"
        user.password.should == "vagrant"
        user.should be_enabled
      end
  
      it "should not return a user that is not enabled" do
        user = server_user.find(:root)
        user.should be_nil
      end
  
      it "should return a disabled user when sent the param ignore_disabled" do
        user = server_user.find(:root, {:include_disabled => true})
        user.role.should     == "root"
        user.username.should == "root"
        user.password.should == "vagrant"
        user.should_not be_enabled
      end
    end
  
    describe ".find_by_role_priority" do
      it "should return the first enabled user matching the order of roles given" do
        prioritized_roles = %w(root personal install app)
        user = server_user.find_by_role_priority prioritized_roles
        user.role.should     == "install"
        user.username.should == "sysadmin"
        user.should be_enabled
      end
    end
  
  end
end
