$:.push File.expand_path("../lib", __FILE__)
require "policy/version"

Gem::Specification.new do |s|
  s.name        = "hexx-validators"
  s.version     = Policy::VERSION.dup
  s.author      = "Andrew Kozin"
  s.email       = "andrew.kozin@gmail.com"
  s.homepage    = "https://github.com/nepalez/hexx"
  s.summary     = "Policy Objects for Ruby."
  s.description = "Tiny library to implement Policy Object pattern."
  s.license     = "MIT"

  s.require_paths    = ["lib"]
  s.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.test_files       = Dir["spec/**/*.rb"]
  s.extra_rdoc_files = Dir["README.md", "LICENSE", "config/metrics/STYLEGUIDE"]

  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = "~> 2.1" # The constraint for the 'hexx-suit'

  s.add_runtime_dependency "activemodel", ">= 3.1", "< 5.0"

  s.add_development_dependency "hexx-suit", "~> 0.0"
end
