$LOAD_PATH.push(File.expand_path('lib', __dir__))
require 'docker-rspec/version'

Gem::Specification.new do |s|
  s.name          = 'docker-rspec'
  s.version       = '0.1.1'
  s.date          = '2018-09-12'
  s.summary       = 'Rake task to run puppet rspec tests in Docker'
  s.licenses      = ['Apache']
  s.authors       = ['Travis Fields']
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.add_runtime_dependency 'docker-api', '~> 1.34'
end
