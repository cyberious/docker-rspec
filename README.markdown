# Docker Rspec for Puppet

### Requirements
A nix environment running Docker

Include the gem in your Gemfile
~~~
  gem 'docker-rspec', '>= 0', { :git => "https://github.com/cyberious/docker-rspec.git"}
~~~

Add the following like to the top of your `Rakefile`
~~~
require 'docker-rspec/tasks/docker-rspec'
~~~

Once you have updated the two files perform a bundle update and ensure Docker is running. Then you can run `bundle exec rake dspec`