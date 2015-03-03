require 'spec_helper'
require 'capistrano/srv_hosts'
require 'capistrano/all'

describe Capistrano::SrvHosts do
  before(:all) do
    @test_data = [
      srv_record(15, 1000, 0, 'server04.example.com'),
      srv_record(10, 1000, 0, 'server03.example.com'),
      srv_record(10, 1000, 0, 'server02.example.com'),
      srv_record(10, 1005, 0, 'server01.example.com')
    ]
  end

  let(:dsl) { Class.new.extend(Capistrano::SrvHosts::DSL).extend(Capistrano::DSL) }

  before { Capistrano::Configuration.reset! }

  describe '#srv_hosts' do
    before :each do
      expect_any_instance_of(Resolv::DNS)
        .to receive(:getresources)
        .with('_test._tcp.example.com', Resolv::DNS::Resource::IN::SRV)
        .exactly(1).times
        .and_return(@test_data)
    end

    it 'should query DNS and cache results' do
      dsl.srv_hosts('_test._tcp.example.com')
      dsl.srv_hosts('_test._tcp.example.com')
    end

    it 'should sort the results properly' do
      res = dsl.srv_hosts('_test._tcp.example.com')
      expect(res.size).to eq(4)
      expect(res).to eq(['server02.example.com', 'server03.example.com', 'server01.example.com', 'server04.example.com'])
    end

    it 'should set user parameter to host' do
      res = dsl.srv_hosts('_test._tcp.example.com', user: "testuser")
      expect(res).to include('testuser@server02.example.com')
    end
  end

  describe '#srv_role' do
    it 'should define the role' do
      expect(dsl).to receive(:srv_hosts).and_return(['server01.example.com', 'server02.example.com'])
      dsl.srv_role :app, '_test._tcp.example.com'
      expect(dsl.roles(:app).map(&:hostname)).to eq(['server01.example.com', 'server02.example.com'])
    end

    it 'should handle role params' do
      expect(dsl).to receive(:srv_hosts).and_return(['server01.example.com'])
      dsl.srv_role :app, '_test._tcp.example.com', :primary => true
      expect(dsl.roles(:app, :primary).size).to eq(1)
    end
  end

  def srv_record(priority, weight, port, host)
    Resolv::DNS::Resource::IN::SRV.new(priority, weight, port, host)
  end
end
