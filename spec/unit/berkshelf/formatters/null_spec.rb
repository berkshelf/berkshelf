require 'spec_helper'

module Berkshelf
  describe NullFormatter do
    it_behaves_like 'a formatter object'

    it 'does not raise an error for abstract metods methods' do
      expect { subject.install }.to_not raise_error
      expect { subject.use }.to_not raise_error
      expect { subject.msg }.to_not raise_error
    end
  end
end
