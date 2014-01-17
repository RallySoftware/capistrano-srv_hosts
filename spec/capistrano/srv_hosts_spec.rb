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

  before do
    Capistrano::Configuration.reset!
  end

  describe '#srv_hosts' do
    it 'should query DNS and cache results' do
      Resolv::DNS.any_instance.should_receive(:getresources).with('_test._tcp.example.com', Resolv::DNS::Resource::IN::SRV).exactly(1).times.and_return(@test_data)
      dsl.srv_hosts('_test._tcp.example.com')
      dsl.srv_hosts('_test._tcp.example.com')
    end

    it 'should sort the results properly' do
      Resolv::DNS.any_instance.should_receive(:getresources).with('_test._tcp.example.com', Resolv::DNS::Resource::IN::SRV).exactly(1).times.and_return(@test_data)
      res = dsl.srv_hosts('_test._tcp.example.com')
      res.size.should eq(4)
      res.should eq(['server02.example.com', 'server03.example.com', 'server01.example.com', 'server04.example.com'])
    end
  end

  describe '#srv_role' do
    it 'should define the role' do
      dsl.should_receive(:srv_hosts).and_return(['server01.example.com', 'server02.example.com'])
      dsl.srv_role :app, '_test._tcp.example.com'
      dsl.roles(:app).map(&:hostname).should eq ['server01.example.com', 'server02.example.com']
    end

    it 'should handle role params' do
      dsl.should_receive(:srv_hosts).and_return(['server01.example.com'])
      dsl.srv_role :app, '_test._tcp.example.com', :primary => true
      dsl.roles(:app, :primary).size.should eq(1)
    end
  end

  def srv_record(priority, weight, port, host)
    Resolv::DNS::Resource::IN::SRV.new(priority, weight, port, host)
  end
end
