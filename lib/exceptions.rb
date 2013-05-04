module Exceptions

  class Server

    # Usage: raise Exceptions::Server::InvalidCurrentUser.new
    class InvalidCurrentUser < StandardError
      def initialize; end

      def to_s
        "current user not assigned or invalid."
      end
    end

    # Usage: raise Exceptions::Server::InceptionUser.new
    class InceptionUser < StandardError
      def initialize; end

      def to_s
        "cannot switch users more than one level deep. Inception hurts my brain."
      end
    end

  end

end
