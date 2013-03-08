module SUPPORT
  class Server
    attr_accessor :ip, :port, :hostname, :user, :password

    def initialize(name="primary")
      server ||= SUPPORT.config["servers"]["#{name}"]
      self.ip = server["ip"]
      self.port = server["port"]
      self.user = server["user"]
      self.password = server["password"]
      self.hostname = server["hostname"]
      server
    end

  end
end
