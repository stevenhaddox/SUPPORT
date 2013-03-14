require 'SUPPORT'
require 'awesome_print'

namespace :support do
  desc "Test server connectivity"
  task :test, :server_name do |t, args|
    args.with_defaults(:server_name => "primary")
    server = SUPPORT::Server.new(args[:server_name])
    begin
      response = server.exec "uname -a"
      ap response.stdout
    rescue => e
      raise e
    end
  end

  desc "Initialize a new SUPPORT Server"
  task :setup, :server_name do |t, args|
    args.with_defaults(:server_name => "primary")
    server = SUPPORT::Server.new(args[:server_name])
    puts "[#{server.hostname}]"
    puts "  Copying SSH Key..."
    response = server.scp_pubkey
    if response.success == true
      puts "  >> SSH Key successfully uploaded."
    else
      puts "  >> There was an error uploading your SSH Key."
      raise ap response
    end
  end
end
