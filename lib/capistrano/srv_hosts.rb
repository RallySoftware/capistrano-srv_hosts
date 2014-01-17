require 'capistrano'
require 'resolv'

module Capistrano::SrvHosts
  module DSL
    def srv_hosts(srv_record)
      @srv_hosts ||= {}
      @srv_hosts[srv_record] ||= Resolv::DNS.open do |dns|
        dns.getresources(srv_record, Resolv::DNS::Resource::IN::SRV).sort_by{|rr| [rr.priority, rr.weight, rr.target.to_s]}.map{ |rr| rr.target.to_s}
      end
      @srv_hosts[srv_record].dup
    end

    def srv_role(new_role, srv_record, *params)
      role new_role, srv_hosts(srv_record), *params
    end
  end
end

self.extend Capistrano::SrvHosts::DSL
