module SUPPORT
  class User
    attr_accessor :role, :username, :password

    def initialize(data)
      @role = data[:role]
      @username = data[:username]
      @password = data[:password]
    end

  end
end
