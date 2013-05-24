require 'spec_helper'
require 'capistrano/srv_hosts'

describe Capistrano::SRVHosts do
  before(:all) do
    @test_data = [
      srv_record(15, 1000, 0, 'server04.example.com'),
      srv_record(10, 1000, 0, 'server03.example.com'),
      srv_record(10, 1000, 0, 'server02.example.com'),
      srv_record(10, 1005, 0, 'server01.example.com')
    ]
  end

  before(:each) do 
    @configuration = Capistrano::Configuration.new
    Capistrano::SRVHosts.load_into(@configuration)
  end

  it 'should load instance methods into Capistrano' do
    @configuration.methods.should include(:srv_hosts)
    @configuration.methods.should include(:srv_role)
  end

  describe '#srv_hosts' do
    it 'should query DNS and cache results' do
      Resolv::DNS.any_instance.should_receive(:getresources).with('_test._tcp.example.com', Resolv::DNS::Resource::IN::SRV).exactly(1).times.and_return(@test_data)
      @configuration.srv_hosts('_test._tcp.example.com')
      @configuration.srv_hosts('_test._tcp.example.com')
    end

    it 'should sort the results properly' do
      Resolv::DNS.any_instance.should_receive(:getresources).with('_test._tcp.example.com', Resolv::DNS::Resource::IN::SRV).exactly(1).times.and_return(@test_data)
      res = @configuration.srv_hosts('_test._tcp.example.com')
      res.size.should eq(4)
      res.should eq(['server02.example.com', 'server03.example.com', 'server01.example.com', 'server04.example.com'])
    end
  end

  describe '#srv_role' do
    it 'should define the role' do
      @configuration.should_receive(:srv_hosts).and_return(['server01.example.com', 'server02.example.com'])
      @configuration.srv_role :app, '_test._tcp.example.com'
      @configuration.roles[:app].servers.size.should eq(2)
      @configuration.roles[:app].servers.map(&:to_s).should eq(['server01.example.com', 'server02.example.com'])
    end

    it 'should handle role params' do
      @configuration.should_receive(:srv_hosts).and_return(['server01.example.com'])
      @configuration.srv_role :app, '_test._tcp.example.com', :primary => true
      @configuration.roles[:app].servers.size.should eq(1)
      @configuration.roles[:app].servers.first.options.should eq({:primary => true})
    end
  end

  def srv_record(priority, weight, port, host)
    Resolv::DNS::Resource::IN::SRV.new(priority, weight, port, host)
  end
end
