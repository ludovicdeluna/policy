$:.push File.expand_path("../lib", __FILE__)
require "policy/version"

Gem::Specification.new do |s|
  s.name        = "hexx-validators"
  s.version     = Policy::VERSION.dup
  s.author      = "Andrew Kozin"
  s.email       = "andrew.kozin@gmail.com"
  s.homepage    = "https://github.com/nepalez/hexx"
  s.summary     = "Policy Objects for Ruby."
  s.description = "A tiny library implementing the Policy Object pattern."
  s.license     = "MIT"

  s.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.test_files       = Dir["spec/**/*.rb"]
  s.extra_rdoc_files = Dir["README.md", "LICENSE", "config/metrics/STYLEGUIDE"]
  s.require_paths    = ["lib"]

  s.add_runtime_dependency "activemodel", ">= 3.1"
  s.add_runtime_dependency "adamantium", "~> 0.2"

  s.add_development_dependency "hexx-suit", "~> 0.2", "> 0.2.1"
end
