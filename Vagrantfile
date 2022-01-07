# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'

  config.vm.synced_folder "./.kube", "/root/.kube", docker_consistency: "cached"
  config.vm.synced_folder "./.kube", "/var/lib/istio/.kube", docker_consistency: "cached"

  config.vm.provider "docker" do |d|
    d.build_dir = "."
    d.create_args = [
      "--privileged",
      "--cap-add",
      "NET_ADMIN"
    ]
    d.build_args = [
      "--build-arg",
      "KUBECTL_VERSION=#{ENV['KUBECTL_VERSION']}",
      "--build-arg",
      "ISTIO_VERSION=#{ENV['ISTIO_VERSION']}",
      "--build-arg",
      "ISTIOD_ADDRESS=#{ENV['ISTIOD_ADDRESS']}",
      "--build-arg",
      "ISTIOD_PORT=#{ENV['ISTIOD_PORT']}",
      "--build-arg",
      "VM_APP=#{ENV['VM_APP']}",
      "--build-arg",
      "VM_NAMESPACE=#{ENV['VM_NAMESPACE']}",
      "--build-arg",
      "SERVICE_ACCOUNT=#{ENV['SERVICE_ACCOUNT']}",
      "--build-arg",
      "CLUSTER_NETWORK=#{ENV['CLUSTER_NETWORK']}",
      "--build-arg",
      "VM_NETWORK=#{ENV['VM_NETWORK']}",
      "--build-arg",
      "CLUSTER=#{ENV['CLUSTER']}",
      "--build-arg",
      "MGMT=#{ENV['MGMT']}",
      "--build-arg",
      "CLUSTER1=#{ENV['CLUSTER1']}",
      "--build-arg",
      "ISTIO_CLUSTER=#{ENV['CLUSTER1']}",
      "--add-host",
      "istiod:#{ENV['ISTIOD_ADDRESS']}"
  ]
  # TODO
  # d.vm.network :private_network, type: "dhcp", name: "#{ ENV['DOCKER_NETWORK_NAME']}"
  end

end
