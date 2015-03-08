# encoding: utf-8
begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
  exit
end

# Loads bundler tasks
Bundler::GemHelper.install_tasks

# Loads the Hexx::Suit and its tasks
require "hexx-suit"
Hexx::Suit.install_tasks

# Sets the Hexx::Suit :test task to default
task default: :test
