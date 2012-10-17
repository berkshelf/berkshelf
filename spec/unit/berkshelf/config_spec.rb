require 'spec_helper'

describe Berkshelf::Config do
  its(:vagrant_vm_forward_port) {
    should be_a Hash
    should be_empty
  }

  its(:vagrant_vm_network_bridged) { should be_false }

  its(:vagrant_vm_network_hostonly) { should be_nil }
end
