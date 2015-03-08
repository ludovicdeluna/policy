# encoding: utf-8

guard :rspec, cmd: "bundle exec rspec" do

  watch("spec/spec_helper.rb") { "spec" }

  watch("lib/policy.rb") { "spec" }

  watch(/^lib(.+)\.rb$/) do |m|
    "spec/tests#{ m[1] }_spec.rb"
  end

  watch(/^spec.+_spec\.rb$/)

end # guard :rspec
