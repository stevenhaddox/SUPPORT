module SUPPORT
  class User
    attr_accessor :role, :username, :password, :enabled

    def initialize data
      @role = data[:role]
      @username = data[:username]
      @password = data[:password]
      @enabled  = data[:enabled]
    end

  end
end
