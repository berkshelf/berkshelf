require 'berkshelf/ui'

# @author Seth Vargo <sethvargo@gmail.com>
class ::Thor::Shell::Color
  # Include the Berkshelf UI methods - this is used by both
  # Vagrant and Berkshelf UI
  include ::Berkshelf::UI
end
