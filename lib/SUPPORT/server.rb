require 'net/ssh/simple'
module SUPPORT
  class Server
    attr_accessor :role, :ip, :port, :hostname, :users

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

    def hostname
      host   = @hostname
      host ||= @ip
    end

    def installer
      users.find_by_role_priority %w(root install personal app)
    end

    def deployer
      users.find_by_role_priority %w(app personal install root)
    end

    def current_user= user_or_role
      if user_or_role.class == SUPPORT::User
        @current_user = user_or_role
      else
        @current_user = users.find(user_or_role, :include_disabled => true)
      end
      @current_user
    end

    def current_user
      @current_user
    end

    def switch_user new_user_role
      raise Exceptions::Server::InvalidCurrentUser unless current_user
      raise Exceptions::Server::InceptionUser if current_user.switched_to?
      original_user_role = current_user.role
      self.current_user = new_user_role
      current_user.switched_from = original_user_role
      current_user
    end

    def exec &block
      if current_user.switched_to?
        exec_with_context "sudo -u #{current_user.username} bash -c ", &block
      else
        exec_with_context( &block )
      end
    end

    def exec_with_context prefix_cmd=nil, &block
      begin
        # attempt key-based, passwordless authentication
        # prompts for password if key-based auth not configured
        Net::SSH::Simple.ssh(hostname, "#{prefix_cmd} #{block.call}", login_params)
      rescue => e
        puts "SSH key-based auth or stdin password failed. Attempting with configuration password..."
        Net::SSH::Simple.ssh(hostname, "#{prefix_cmd} #{block.call}", login_params(true))
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
      File.absolute_path SUPPORT.config["pubkey_path"]
    end

    def pubkey
      `cat "#{eval_pubkey_path}"`.rstrip
    end

    def pubkey_exists?
      response = exec {
        "grep '#{pubkey}' $HOME/.ssh/authorized_keys"
      }
      response.exit_code == 0 ? true : false
    end

    def add_pubkey
      unless pubkey_exists?
        response = exec do
          "echo '#{pubkey}' >> $HOME/.ssh/authorized_keys"
        end
      end
      response
    end

    def scp_pubkey
      scp(eval_pubkey_path, "#{current_user.role}_id.pub")
      unless pubkey_exists?
        response = exec do
          "cat $HOME/#{current_user.role}_id.pub >> $HOME/.ssh/authorized_keys"
        end
      end
      exec{ "rm $HOME/#{current_user.role}_id.pub" }
      response
    end

private

    def login_params use_password=false
      user = current_user.switched_to? ? users.find(current_user.switched_from, :include_disabled => true) : current_user
      opts = { :user => user.username, :port => port }
      opts[:password] = user.password if use_password==true
      opts
    end

  end
end
