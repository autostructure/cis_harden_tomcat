require 'spec_helper'

describe 'cis_harden_tomcat::harden_application' do
  let(:title) { 'some_home' }

  let(:params) do
    {
      'catalina_home'     => '/usr/local/tomcat',
      'catalina_base'     => '/usr/local/tomcat',
      'application'       => 'some_app'
    }
  end

  context 'with default values for all parameters' do
    it { should contain_file_line('some_home_logging_handler') }
  end

  context 'with default values for all parameters' do
    let(:pre_condition) { 'file { \'/usr/local/tomcat\': }' }

    it { should contain_file_line('some_home_logging_handler') }
  end
end
