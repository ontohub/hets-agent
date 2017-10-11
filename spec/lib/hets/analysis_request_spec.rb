# frozen_string_literal: true

require 'spec_helper'

describe HetsAgent::Hets::AnalysisRequest do
  before do
    boot_application
  end

  let(:arguments) do
    {
      revision: '0123456789abcdef0123456789abcdef01234567',
      file_path: 'Hets-lib/Basic/RelationsAndOrders.casl',
      file_version_id: 23,
      repository_slug: 'ada/fixtures',
      server_url: 'http://localhost:3000',
      url_mappings: [{'Basic/' => 'Hets-lib/Basic'}],
    }
  end

  subject { HetsAgent::Hets::AnalysisRequest.new(arguments) }

  context 'request' do
    subject { HetsAgent::Hets::LogicGraphRequest.new }
    it_behaves_like 'a HetsAgent::Hets::Request'
  end

  context 'mocking the system call' do
    before do
      allow_any_instance_of(Kernel).to receive(:system)
    end

    it 'has hets as the first argument' do
      expect(subject.arguments.first).to eq(Settings.hets.path.to_s)
    end

    context 'the arguments contain the' do
      let(:libdir) do
        File.join(arguments[:server_url],
                  arguments[:repository_slug],
                  'revision',
                  arguments[:revision],
                  'tree')
      end

      it 'verbosity' do
        expect(subject.arguments).to include('--verbose=5')
      end

      it 'output type' do
        expect(subject.arguments).to include('--output-types=db')
      end

      it 'database.yml' do
        database_yml = HetsAgent::Application.root.join('config/database.yml')
        expect(subject.arguments).
          to include("--database-config=#{database_yml}")
      end

      it 'database subconfig' do
        expect(subject.arguments).
          to include("--database-subconfig=#{HetsAgent::Application.env}")
      end

      it 'hets-libdirs' do
        expect(subject.arguments).to include("--hets-libdirs=#{libdir}")
      end

      it 'automatic rule' do
        expect(subject.arguments).to include('--apply-automatic-rule')
      end

      it 'file_version_id' do
        expect(subject.arguments).
          to include("--database-fileversion-id=#{arguments[:file_version_id]}")
      end

      it 'url catalog' do
        url_mappings =
          [
            {File.join(arguments[:server_url],
                       arguments[:repository_slug],
                       'tree') => File.join(arguments[:server_url],
                                            arguments[:repository_slug],
                                            'revision',
                                            arguments[:revision],
                                            'tree')},
            {File.join(arguments[:server_url],
                        arguments[:repository_slug],
                        'documents') => File.join(arguments[:server_url],
                                                  arguments[:repository_slug],
                                                  'revision',
                                                  arguments[:revision],
                                                  'documents')},
          ] + arguments[:url_mappings]
        url_catalog =
          url_mappings.map do |map|
            source, target = map.to_a.first
            "#{source}=#{target}"
          end.join(',')
        expect(subject.arguments).
          to include("--url-catalog=#{url_catalog}")
      end

      it 'the filepath' do
        expect(subject.arguments).
          to include(File.join(libdir, arguments[:file_path]))
      end
    end
  end
end
