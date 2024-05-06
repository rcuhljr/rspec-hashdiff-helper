# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'rspec_hashdiff_helper'
  s.version = '0.1.1'
  s.required_ruby_version = '>= 3.3.0'
  s.date = '2024-05-06'
  s.summary = 'A library for rspec that displays better hash diffs'
  s.authors = ['Sid Shanker', 'Robert Uhl']
  s.files = ['lib/rspec_hashdiff_helper.rb']
  s.license = 'MIT'
  s.add_runtime_dependency 'hashdiff'
  s.add_runtime_dependency 'rspec'
end
