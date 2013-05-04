require 'spec_helper'

describe "Server" do
  let(:server) { FactoryGirl.build(:server) }

  describe ".initialize" do
    it "should init attributes from config" do
      config_server           = SUPPORT.config["servers"]["primary"]
      server.role.should     == "primary"
      server.ip.should       == config_server["ip"]
      server.port.should     == config_server["port"]
      server.hostname.should == config_server["hostname"]
    end
  end

  describe ".users" do
    it "should return all server users" do
      server_users = SUPPORT::ServerUser.new({:role => server.role})
      server.users.all.map{|u| [u.role, u.username]}.should =~ server_users.all.map{|u| [u.role, u.username]}
    end
  end

  describe ".current_user" do
    it "should assign & access current_user" do
      # role as symbol
      server.current_user = :app
      server.current_user.should == server.users.find('app')
      # role as string
      server.current_user = 'install'
      server.current_user.should == server.users.find(:install)
      # user instance
      server.current_user = server.users.find(:root)
      server.current_user.should == server.users.find(:root)
    end
  end

  describe ".installer" do
    it "should return the user who will install system services" do
      server.installer.username.should == SUPPORT::ServerUser.new({:role => server.role}).find('install').username
    end
  end

  describe ".deployer" do
    it "should return the user who will deploy applications" do
      server.deployer.username.should == SUPPORT::ServerUser.new({:role => server.role}).find('app').username
    end
  end

  describe ".exec" do
    it "should authenticate to the specified remote server" do
      server.current_user= :app
      server_response = server.exec{''}
      server_response.stdout.should == ""
      server_response.success.should == true
      server_response.exit_code.should == 0
    end

    it "should run a command block remotely on the server" do
      server.current_user= :app
      server_response = server.exec{'hostname'}
      server_response.stdout.should == "vagrant-c5-x86_64\n"
      server_response.success.should == true
      server_response.exit_code.should == 0
    end
  end

  describe ".exec_with_context" do
    it "should authenticate to the specified remote server" do
      server.current_user= :app
      server_response = server.exec_with_context {''}
      server_response.stdout.should == ""
      server_response.success.should == true
      server_response.exit_code.should == 0
    end

    it "should run a command block remotely on the server" do
      server.current_user= :app
      server_response = server.exec_with_context {'hostname'}
      server_response.stdout.should == "vagrant-c5-x86_64\n"
      server_response.success.should == true
      server_response.exit_code.should == 0
    end

    it "should run a command block remotely on the server with a prepended command" do
      server.current_user= :root
      block = Proc.new { "grep 'hello'" }
      server_response = server.exec_with_context "echo 'hello'; echo 'world' |", &block
      server_response.stdout.should == "hello\n"
      server_response.success.should == true
    end
  end

  describe ".scp" do
    it "should copy a local file to the server" do
      `rm /tmp/SUPPORT_tmp.txt`
      `touch /tmp/SUPPORT_tmp.txt`
      server.current_user= :app
      server_response = server.scp("/tmp/SUPPORT_tmp.txt")
      server_response.success.should == true
    end
  end

  describe ".switch_user" do
    it "should require .current_user to exist before being able to switch" do
      server.current_user = nil
      expect { server.switch_user(:app) }.to raise_error Exceptions::Server::InvalidCurrentUser
      server.current_user = ""
      expect { server.switch_user(:app) }.to raise_error Exceptions::Server::InvalidCurrentUser
    end

    it "should switch the current_user to the specified user" do
      orig_user_role = :root
      new_user = server.users.find(:app)
      server.current_user = orig_user_role
      server.switch_user(new_user.role)
      server.current_user.username.should == new_user.username
      response = server.exec{ "whoami" }
      response.stdout.rstrip.should == new_user.username
      response.exit_code.should == 0
    end

    it "should not allow switching to a different user if it has already switched to a user" do
      orig_user_role = :root
      new_user = server.users.find(:app)
      server.current_user = orig_user_role
      server.switch_user(new_user.role)
      server.current_user.username.should == new_user.username
      server.current_user.switched_to?.should == true
      expect { server.switch_user(:install) }.to raise_error Exceptions::Server::InceptionUser
    end
  end

  describe ".eval_pubkey_path" do
    it "should have access to the pubkey's location locally" do
      SUPPORT.config["pubkey_path"].should == "./config/id_rsa.vagrant.support.pub"
    end

    it "should eval the pubkey to expand the file's path" do
      server.eval_pubkey_path.should == File.absolute_path(".")+"/config/id_rsa.vagrant.support.pub"
    end
  end

  describe ".pubkey" do
    it "should return the pubkey's contents" do
      server.pubkey.should == "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key for SUPPORT"
    end
  end

  describe "pubkey specs" do
    before :each do
      # backup existing authorized_keys
      server.current_user = :app
      server.exec{"cp $HOME/.ssh/authorized_keys $HOME/.ssh/authorized_keys.bak"}
    end

    after :each do
      # restore backed up authorized_keys
      server.exec{"mv $HOME/.ssh/authorized_keys.bak $HOME/.ssh/authorized_keys"}
    end

    describe ".pubkey_exists?" do
      it "should check the presence of the pubkey in the authorized_keys file" do
        server.pubkey_exists?.should be_false
        server.scp_pubkey
        server.pubkey_exists?.should be_true
      end
    end

    describe ".scp_pubkey" do
      it "should copy the pubkey to the remote server" do
        server_response = server.scp_pubkey
        server_response.exit_code.should == 0
        server_response.stdout.should == ""
      end
    end

    describe ".add_pubkey" do
      it "should append the pubkey to the authorized_keys file" do
        server.pubkey_exists?.should be_false
        server_response = server.add_pubkey
        server_response.exit_code.should == 0
        server.pubkey_exists?.should be_true
      end
    end
  end

  describe ".login_params" do
    context "current_user" do
      before :each do
        server.current_user = :app
        @login_params = server.send(:login_params)
      end

      it "should return the user" do
        @login_params[:user].should == server.users.find(:app).username
      end

      it "should return the port" do
        @login_params[:port].should == server.port
      end

      it "should return the password if use_password is true" do
        @login_params[:password].should == nil
        login_params = server.send(:login_params, true)
        login_params[:password].should == server.users.find(:app).password
      end
    end

    context "current_user.switched_to? == true" do
      before :each do
        server.current_user = :app
        server.switch_user :root
        @login_params = server.send(:login_params)
      end

      it "should return the user" do
        user = server.users.find(server.current_user.switched_from, :included_disabled => true)
        @login_params[:user].should == user.username
      end

      it "should return the password if use_password is true" do
        @login_params[:password].should == nil
        login_params = server.send(:login_params, true)
        user = server.users.find(server.current_user.switched_from, :included_disabled => true)
        login_params[:password].should == user.password
      end
    end
  end
end
