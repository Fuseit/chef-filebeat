require 'spec_helper'

describe 'filebeat::default' do
  shared_examples_for 'filebeat' do
    context 'all_platforms' do
      %w(install config).each do |r|
        it "include recipe filebeat::#{r}" do
          expect(chef_run).to include_recipe("filebeat::#{r}")
        end
      end

      it 'download filebeat package file' do
        expect(chef_run).to create_remote_file('filebeat_package_file')
      end

      it 'create prospector directory /etc/filebeat/conf.d' do
        expect(chef_run).to create_directory('/etc/filebeat/conf.d')
      end

      it 'configure /etc/filebeat/filebeat.yml' do
        expect(chef_run).to create_file('/etc/filebeat/filebeat.yml')
      end

      it 'enable filebeat service' do
        expect(chef_run).to enable_service('filebeat')
        expect(chef_run).to start_service('filebeat')
      end
    end
  end

  context 'rhel' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.4') do |node|
        node.automatic['platform_family'] = 'rhel'
      end.converge(described_recipe)
    end

    include_examples 'filebeat'

    it 'install filebeat package' do
      expect(chef_run).to install_package('filebeat')
    end
  end

  context 'ubuntu' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04') do |node|
        node.automatic['platform_family'] = 'debian'
      end.converge(described_recipe)
    end

    include_examples 'filebeat'

    it 'install filebeat package' do
      expect(chef_run).to install_package('filebeat')
    end
  end

  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2008R2') do |node|
        node.automatic['platform_family'] = 'windows'
      end.converge(described_recipe)
    end

    include_examples 'filebeat'

    it 'create filebeat base dir C:/opt/filebeat/' do
      expect(chef_run).to create_directory('C:/opt/filebeat/')
    end

    it 'unzip filebeat package file to C:/opt/filebeat/' do
      expect(chef_run).to unzip_windows_zipfile_to('C:/opt/filebeat/')
    end
  end
end
