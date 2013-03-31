module SUPPORT
  class ServerUser
    attr_accessor :server, :users

    def initialize args
      role = args.fetch(:role)
      SUPPORT.config["servers"][role]["users"].each{|data| add_user(data) }
    end

    def add_user data
      @users ||= []
      @users << SUPPORT::User.new({
        :role => data[0],
        :username => data[1]["username"],
        :password => data[1]["password"],
        :enabled  => data[1]["enabled"]
      })
    end

    def all
      @users
    end

    def find role, opts={}
      opts[:include_disabled] ||= false
      opts[:include_disabled]==true ? find_and_include_disabled(role) : find_enabled(role)
    end

    def find_enabled role
      all.select{|user| user.role == role.to_s && user.enabled}.compact.first
    end

    def find_and_include_disabled role
      all.select{|user| user.role == role.to_s}.compact.first
    end

    def find_by_role_priority roles
      user = nil
      roles.each do |role|
        user ||= find(role)
      end
      user
    end

  end
end
