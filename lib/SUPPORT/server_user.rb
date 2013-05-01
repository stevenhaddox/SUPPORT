module SUPPORT
  class ServerUser
    attr_accessor :server

    def initialize args
      role = args.fetch(:role)
      SUPPORT.config["servers"][role]["users"].each{|data| add_user(data) }
    end

    def add_user data
      users << SUPPORT::User.new({
        :role => data[0],
        :username => data[1]["username"],
        :password => data[1]["password"],
        :enabled  => data[1]["enabled"]
      })
    end

    def all
      users
    end

    def enabled
      all.map{|u| u if u.enabled? }
    end

    def users
      @users ||= []
    end

    def find role, opts={}
      defaults = {include_disabled: false}.merge opts
      defaults[:include_disabled] ? find_and_include_disabled(role) : find_enabled(role)
    end

    def find_enabled role
      all.detect{|user| user.role == role.to_s && user.enabled?}
    end

    def find_and_include_disabled role
      all.detect{|user| user.role == role.to_s}
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
