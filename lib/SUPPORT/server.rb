require 'awesome_print'

module SUPPORT
  class Server
    attr_accessor :ip, :hostname, :user, :password

    def initialize(name="primary")
      server ||= SUPPORT.config["servers"]["#{name}"]
      self.ip = server["ip"]
      self.user = server["user"]
      self.password = server["password"]
      self.hostname = server["hostname"]
      server
    end

  end
end
