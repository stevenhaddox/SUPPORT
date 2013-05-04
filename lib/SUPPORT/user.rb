module SUPPORT
  class User
    attr_accessor :role, :username, :password, :enabled, :switched_from

    alias :enabled? :enabled

    def initialize data
      @role = data[:role]
      @username = data[:username]
      @password = data[:password]
      @enabled  = data[:enabled]
    end

    def switched_from= user_role
      @switched_from = user_role
    end

    def switched_to?
      !!@switched_from
    end

  end
end
