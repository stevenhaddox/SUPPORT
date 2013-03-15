require 'net/ssh/simple'
module SUPPORT
  class Server
    attr_accessor :role, :ip, :port, :hostname, :users, :password, :root

    def initialize(role="primary",user="install")
      user = user.to_s
      @role     = role.to_s

      server  ||= SUPPORT.config["servers"][role]
      @ip       = server["ip"]
      @port     = server["port"]
      @hostname = server["hostname"]
      @users    = server["users"].map do |user|
        User.new(user[0], user[1]["username"], user[1]["password"])
      end
    end

    User = Struct.new(:role, :username, :password) {}
    def user(role='install')
      users.collect{|u| u if u.role==role.to_s}.compact.first
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

    def scp(local_file, remote_file=nil)
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
      scp(eval_pubkey_path, "id_dsa.pub")
      response = exec do
        "if grep -f \"$HOME/id_dsa.pub\" $HOME/.ssh/authorized_keys
         then
           echo 'SSH pubkey already in authorized_keys!'
         else
           cat $HOME/id_dsa.pub >> $HOME/.ssh/authorized_keys
           rm $HOME/id_dsa.pub
         fi"
      end
    end

    def setup

    end

private

    def login_params(use_password=false)
      opts = { :user => user, :port => port }
      opts[:password] = password if use_password==true
      opts
    end

  end
end
