require 'capistrano'
require 'resolv'

module Capistrano::SrvHosts
  module InstanceMethods
    def srv_hosts(srv_record)
      @srv_hosts ||= {}
      @srv_hosts[srv_record] ||= Resolv::DNS.open do |dns|
        dns.getresources(srv_record, Resolv::DNS::Resource::IN::SRV).sort_by{|rr| [rr.priority, rr.weight, rr.target.to_s]}.map{ |rr| rr.target.to_s}
      end
      @srv_hosts[srv_record].dup
    end
    
    def srv_role(new_role, srv_record, *params)
      role new_role, *srv_hosts(srv_record), *params
    end
  end

  def self.load_into(configuration)
    configuration.load do
      extend InstanceMethods 
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::SrvHosts.load_into(Capistrano::Configuration.instance(:must_exist))
end
