require 'spec_helper'
describe 'nanitor_agent' do
  context 'with default values for all parameters' do
    it { should contain_class('nanitor_agent') }
  end
end
