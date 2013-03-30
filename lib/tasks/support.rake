require 'SUPPORT'
require 'awesome_print'

namespace :support do
  desc "Test server connectivity."
  task :test, :server_role, :user_role do |t, args|
    args.with_defaults(:server_role => "primary",:user_role => "install")
    server = SUPPORT::Server.new({:role => args[:server_role]})
    server.current_user = args[:user_role]
    begin
      response = server.exec{ "uname -a" }
      ap response.stdout
    rescue => e
      raise e
    end
  end

  desc "Identify the installer & deployer users for a server."
  task :identify_users, :server_role do |t, args|
    args.with_defaults(:server_role => "primary")
    server = SUPPORT::Server.new({:role => args[:server_role]})
    puts "[#{server.role}] server:"
    puts "  [Installer]"
    puts "    User Role: #{server.installer.role}"
    puts "    Username:  #{server.installer.username}"
    puts "  [Deployer]"
    puts "    User Role: #{server.deployer.role}"
    puts "    Username:  #{server.deployer.username}"
  end

  desc "Initialize a new SUPPORT Server."
  task :setup, :server_role, :user_role do |t, args|
    args.with_defaults(:server_role => "primary",:user_role => "install")
    server = SUPPORT::Server.new({:role => args[:server_role]})
    server.current_user = args[:user_role]
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
