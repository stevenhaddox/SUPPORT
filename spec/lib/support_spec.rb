require 'spec_helper'

describe SUPPORT do

  describe "#config" do
    it "should load the values from config/support.toml" do
      SUPPORT.config.should == TOML.load_file('config/support.toml.example')
    end
  end

end
