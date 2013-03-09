require 'net/ssh/simple'
module SUPPORT
  class Server
    attr_accessor :role, :ip, :port, :hostname, :user, :password

    def initialize(role="primary")
      server ||= SUPPORT.config["servers"]["#{role}"]
      @role     = role
      @ip       = server["ip"]
      @port     = server["port"]
      @user     = server["user"]
      @password = server["password"]
      @hostname = server["hostname"]
      server
    end

    def hostname
      host = @hostname
      host ||= ip
    end

    def exec(&block)
      begin
        # attempt key-based, passwordless authentication
        # prompts for password if key-based auth not configured
        Net::SSH::Simple.ssh(hostname, yield, {:user => @user, :port => @port})
      rescue => e
        puts "SSH key-based auth or stdin password failed. Attempting with configuration password..."
        Net::SSH::Simple.ssh(hostname, yield, {:user => @user, :password => @password, :port => @port})
      end
    end

    def scp(local_file, remote_file)
      begin
        Net::SSH::Simple.scp_put(hostname, local_file, remote_file, {:user => @user, :port => @port})
      rescue => e
        puts "SCP with key-based auth or stdin password failed. Attempting with configuration password..."
        Net::SSH::Simple.scp_put(hostname, local_file, remote_file, {:user => @user, :password => @password, :port => @port})
      end
    end

  end
end
