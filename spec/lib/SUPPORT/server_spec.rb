require 'spec_helper'

describe "Server" do
  context ".setup" do
    it "should copy the pubkey to the remote server" do
      SUPPORT.config["pub_key_path"].should == "$HOME/.ssh/id_dsa.pub"
    end
  end
end
