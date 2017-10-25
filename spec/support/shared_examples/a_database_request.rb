# frozen_string_literal: true

RSpec.shared_examples 'a database request' do
  it 'output type' do
    expect(subject.arguments).to include('--output-types=db')
  end

  it 'disable database migration' do
    expect(subject.arguments).to include('--database-do-not-migrate')
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
end
