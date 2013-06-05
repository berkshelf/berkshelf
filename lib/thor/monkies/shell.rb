require 'berkshelf/ui'

# Include the Berkshelf UI methods - this is used by both Vagrant and Berkshelf
Thor::Base.shell.send(:include, Berkshelf::UI)
