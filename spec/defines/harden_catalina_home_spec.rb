require 'spec_helper'

describe 'cis_harden_tomcat::harden_catalina_home' do
  let(:title) { 'some_home' }

  let(:facts) { { 'augeasversion' => '1.2.3' } }

  context 'with default values for all parameters' do
    let(:params) do
      {
        'catalina_home' => '/usr/local/tomcat'
      }
    end

    it { should contain_augeas('Disable client facing Stack Traces') }
  end

  context 'with default values for all parameters with tomcat home already created' do
    let(:params) do
      {
        'catalina_home' => '/usr/local/tomcat'
      }
    end

    let(:pre_condition) { 'file { \'/usr/local/tomcat\': }' }

    it { should contain_augeas('Disable client facing Stack Traces') }
  end

  context 'with remove_extraneous_files_and_directories values set to true' do
    let(:params) do
      {
        'catalina_home' => '/usr/local/tomcat',
        'remove_extraneous_files_and_directories' => true
      }
    end

    it { should contain_file('/usr/local/tomcat/webapps/examples') }
  end
end
