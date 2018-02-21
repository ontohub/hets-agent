# frozen_string_literal: true

RSpec.describe 'HetsAgent::SettingsSchema' do
  subject { Dry::Validation.Schema(HetsAgent::SettingsSchema).call(settings) }
  let(:settings) do
    {hets: {path: '/path/to/hets'},
     agent: {id: 1},
     backend: {api_key: 'API_KEY'},
     rabbitmq: {host: 'localhost',
                port: 1234,
                username: 'username',
                password: 'password',
                virtual_host: 'virtual_host'},
     sneakers: {workers: 1}}
  end

  before do
    [settings[:hets][:path]].each do |file|
      allow(File).to receive(:file?).with(file).and_return(true)
      allow(File).to receive(:executable?).with(file).and_return(true)
    end
  end

  it 'passes' do
    expect(subject.errors).to be_empty
  end

  context 'fails if the' do
    context 'hets' do
      context 'path' do
        context 'has a bad type' do
          it 'fails' do
            settings[:hets][:path] = 1
            expect(subject.errors).
              to include(hets: include(path: ['must be a string']))
          end
        end

        it 'is not a file' do
          allow(File).
            to receive(:file?).
            with(settings[:hets][:path].to_s).
            and_return(false)
          expect(subject.errors).
            to include(hets: include(path: ['is not an executable file']))
        end

        it 'is not an _executable_ file' do
          allow(File).
            to receive(:executable?).
            with(settings[:hets][:path].to_s).
            and_return(false)
          expect(subject.errors).
            to include(hets: include(path: ['is not an executable file']))
        end
      end
    end

    context 'agent' do
      context 'id' do
        it 'is nil' do
          settings[:agent][:id] = nil
          expect(subject.errors).
            to include(agent: include(id: ['must be filled']))
        end
      end
    end

    context 'backend' do
      context 'api_key' do
        it 'is nil' do
          settings[:backend][:api_key] = nil
          expect(subject.errors).
            to include(backend: include(api_key: ['must be filled']))
        end

        it 'has a bad type' do
          settings[:backend][:api_key] = nil
          expect(subject.errors).
            to include(backend: include(api_key: ['must be filled']))
        end
      end
    end

    context 'rabbitmq' do
      %i(host username password virtual_host).each do |field|
        context field.to_s do
          it 'is nil' do
            settings[:rabbitmq][field] = nil
            expect(subject.errors).
              to include(rabbitmq: {field => ['must be filled']})
          end

          it 'is maltyped' do
            settings[:rabbitmq][field] = 0
            expect(subject.errors).
              to include(rabbitmq: {field => ['must be a string']})
          end
        end
      end
      context 'port' do
        it 'is nil' do
          settings[:rabbitmq][:port] = nil
          expect(subject.errors).
            to include(rabbitmq: {port: ['must be filled']})
        end

        it 'is maltyped' do
          settings[:rabbitmq][:port] = 'string'
          expect(subject.errors).
            to include(rabbitmq: {port: ['must be an integer']})
        end
      end
    end

    context 'sneakers' do
      context 'workers' do
        it 'is not an integer' do
          settings[:sneakers] = {workers: 'bad'}
          expect(subject.errors).to include(
            sneakers: include(workers: ['must be an integer'])
          )
        end
      end
    end
  end
end
