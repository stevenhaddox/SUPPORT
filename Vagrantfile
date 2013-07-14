Vagrant::Config.run do |config|
  config.vm.box = "vagrant-centos59-x86_64-SUPPORT"
  config.vm.box_url = "http://bit.ly/SUPPORT-x64"

  config.vm.network :hostonly, "33.33.33.10"
  config.vm.share_folder "v-cookbooks", "/cookbooks", "."
end
