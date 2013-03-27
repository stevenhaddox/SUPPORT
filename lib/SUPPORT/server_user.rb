module SUPPORT
  class ServerUser
    attr_accessor :server, :users

    def initialize(args)
      role = args.fetch(:role)
      SUPPORT.config["servers"][role]["users"].each{|data| add_user(data) }
    end

    def add_user(data)
      @users ||= []
      @users << SUPPORT::User.new({:role => data[0], :username => data[1]["username"], :password => data[1]["password"]})
    end

    def all
      @users
    end

    def find(role)
      all.collect{|user| user if user.role == role.to_s}.compact.first
    end

  end
end
