Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04-arm64"
  config.vm.box_version = "202306.30.0"
  config.vm.box_download_insecure = true
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.synced_folder ".", "/home/vagrant/mongodb-cluster"
  config.vm.provider "vmware_desktop" do |v|
      v.ssh_info_public = true
      v.gui = true
      v.linked_clone = false
      v.vmx["ethernet0.virtualdev"] = "vmxnet3"
  end
end
