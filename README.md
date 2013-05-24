# Capistrano::SRVHosts [![Build Status](https://travis-ci.org/RallySoftware/capistrano-srv_hosts.png)](https://travis-ci.org/RallySoftware/capistrano-srv_hosts)

Capistrano extension to fetch deploy hosts via DNS SRV records.

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-srv-hosts'

And then execute:

    $ bundle

Or install it yourself:

    $ gem install capistrano-srv-hosts

## Usage

Create appropriate DNS records, e.g.:

    # service proto name ttl class type priority weight port target
    _service._tcp.example.com 3600 IN SRV 10 1000 0 server01.example.com
    _service._tcp.example.com 3600 IN SRV 20 1000 0 server02.example.com

Configure your config/deploy.rb:

At the top add:

```ruby
require 'capistrano/srv_hosts'
```

Then you can define roles like this:

```ruby
srv_role :app, '_service._tcp.example.com'
srv_role :web, '_service._tcp.example.com', :primary => true
```

And like this:

```ruby
role :db, srv_hosts('_service._tcp.example.com').first, :primary => true
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

© Rally Software Development Corp. Released under MIT license, see
[LICENSE](https://github.com/RallySoftware/openid-store-redis/blob/master/LICENSE.txt)
for details.
