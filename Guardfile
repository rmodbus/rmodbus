# frozen_string_literal: true

guard "rspec" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { "spec" }
  watch("spec/spec_helper.rb") { "spec" }
end
