require 'spec_helper'

describe 'cis_harden_tomcat::harden_catalina_home' do
  let(:title) { 'some_home' }

  let(:facts) { { 'augeasversion' => '1.2.3' } }

  let(:params) do
    {
      'catalina_home' => '/usr/local/tomcat'
    }
  end

  context 'with default values for all parameters' do
    it { should contain_augeas('Disable client facing Stack Traces') }
  end
end
