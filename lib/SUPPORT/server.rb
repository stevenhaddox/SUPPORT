require 'net/ssh/simple'
module SUPPORT
  class Server
    attr_accessor :role, :ip, :port, :hostname, :users, :current_user

    def initialize args={}
      args      = defaults.merge(args)
      @role     = args[:role].to_s

      config    = SUPPORT.config["servers"][role]
      @ip       = config["ip"]
      @port     = config["port"]
      @hostname = config["hostname"]
      @users    = SUPPORT::ServerUser.new({:role => @role})
    end

    def defaults
      {:role => "primary"}
    end

    def installer
      users.find_by_role_priority %w(root install personal app)
    end

    def deployer
      users.find_by_role_priority %w(app personal install root)
    end

    def current_user= role
      @current_user = users.find(role)
    end

    def current_user
      @current_user ||= user
    end

    def hostname
      host = @hostname
      host ||= ip
    end

    def exec &block
      begin
        # attempt key-based, passwordless authentication
        # prompts for password if key-based auth not configured
        Net::SSH::Simple.ssh(hostname, yield, login_params)
      rescue => e
        puts "SSH key-based auth or stdin password failed. Attempting with configuration password..."
        Net::SSH::Simple.ssh(hostname, yield, login_params(true))
      end
    end

    def scp local_file, remote_file=nil
      remote_file ||= local_file
      begin
        Net::SSH::Simple.scp_put(hostname, local_file, remote_file, login_params)
      rescue => e
        puts "SCP with key-based auth or stdin password failed. Attempting with configuration password..."
        Net::SSH::Simple.scp_put(hostname, local_file, remote_file, login_params(true))
      end
    end

    def eval_pubkey_path
      `ls "#{SUPPORT.config["pubkey_path"]}"`.rstrip
    end

    def scp_pubkey
      scp(eval_pubkey_path, "#{current_user.role}_id.pub")
      response = exec do
        "if grep -f \"$HOME/#{current_user.role}_id.pub\" $HOME/.ssh/authorized_keys
         then
           echo 'SSH pubkey already in authorized_keys!'
         else
           cat $HOME/#{current_user.role}_id.pub >> $HOME/.ssh/authorized_keys
         fi"
      end
      exec{ "rm $HOME/#{current_user.role}_id.pub" }
      response
    end

private

    def login_params use_password=false
      opts = { :user => current_user.username, :port => port }
      opts[:password] = current_user.password if use_password==true
      opts
    end

  end
end
