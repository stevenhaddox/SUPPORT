require 'SUPPORT'
require 'awesome_print'

namespace :support do
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
