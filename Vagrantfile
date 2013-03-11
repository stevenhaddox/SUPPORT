Vagrant::Config.run do |config|
  config.vm.box = "centos-5.9-x86-64-minimal.box"
  config.vm.box_url = "http://tag1consulting.com/files/centos-5.9-x86-64-minimal.box"
  config.vm.network :hostonly, "33.33.33.10"
  config.vm.share_folder "v-cookbooks", "/cookbooks", "."
end
