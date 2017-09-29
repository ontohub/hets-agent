# frozen_string_literal: true

require 'spec_helper'

describe HetsAgent::Hets::AnalysisCaller do
  before do
    HetsAgent::Application.boot
  end

  context 'mocking the system call' do
    before do
      allow_any_instance_of(Kernel).to receive(:system)
    end

    let(:analysis_caller) { HetsAgent::Hets::AnalysisCaller.new(arguments) }

    # Since we test with
    # expect_any_instance_of(Kernel).to receive(:system).with(...)
    # The caller needs to be called after executing the it-block.
    after do
      analysis_caller.call
    end

    let(:arguments) do
      {
        revision: '0123456789abcdef0123456789abcdef01234567',
        file_path: 'Hets-lib/Basic/RelationsAndOrders.casl',
        file_version_id: 23,
        repository_slug: 'ada/fixtures',
        server_url: 'http://localhost:3000',
        url_mappings: {'Basic/' => 'Hets-lib/Basic'},
      }
    end

    it 'calls hets with the arguments' do
      expect_any_instance_of(Kernel).
        to receive(:system).
        with(*analysis_caller.arguments)
    end

    it 'has hets as the first argument' do
      expect(analysis_caller.arguments.first).to eq(Settings.hets.path.to_s)
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
        expect(analysis_caller.arguments).to include('--verbose=5')
      end

      it 'output type' do
        expect(analysis_caller.arguments).to include('--output-types=db')
      end

      it 'database.yml' do
        database_yml = HetsAgent::Application.root.join('config/database.yml')
        expect(analysis_caller.arguments).
          to include("--database-config=#{database_yml}")
      end

      it 'database subconfig' do
        expect(analysis_caller.arguments).
          to include("--database-subconfig=#{HetsAgent::Application.env}")
      end

      it 'hets-libdirs' do
        expect(analysis_caller.arguments).to include("--hets-libdirs=#{libdir}")
      end

      it 'automatic rule' do
        expect(analysis_caller.arguments).to include('--apply-automatic-rule')
      end

      it 'file_version_id' do
        expect(analysis_caller.arguments).
          to include("--database-fileversion-id=#{arguments[:file_version_id]}")
      end

      it 'url catalog' do
        url_mappings =
          {
            File.join(arguments[:server_url],
                      arguments[:repository_slug],
                      'tree') => File.join(arguments[:server_url],
                                           arguments[:repository_slug],
                                           'revision',
                                           arguments[:revision],
                                           'tree'),
            File.join(arguments[:server_url],
                      arguments[:repository_slug],
                      'documents') => File.join(arguments[:server_url],
                                                arguments[:repository_slug],
                                                'revision',
                                                arguments[:revision],
                                                'documents'),
          }.merge(arguments[:url_mappings])
        url_catalog =
          url_mappings.map { |source, target| "#{source}=#{target}" }.join(',')
        expect(analysis_caller.arguments).
          to include("--url-catalog=#{url_catalog}")
      end

      it 'the filepath' do
        expect(analysis_caller.arguments).
          to include(File.join(libdir, arguments[:file_path]))
      end
    end
  end
end
