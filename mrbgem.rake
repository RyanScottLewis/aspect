require "pathname"

MRuby::Gem::Specification.new("aspect") do |spec|
  spec.summary = "A small collection of useful classes, modules, and mixins for plain old Ruby objects."
  spec.license = "MIT"

  spec.authors = "Ryan Scott Lewis <ryan@rynet.us>"
  spec.version = Pathname.glob("VERSION*").first.read rescue "0.0.0"

  spec.rbfiles = []

  spec.rbfiles << "#{dir}/lib/aspect.rb"
  spec.rbfiles << "#{dir}/lib/aspect/has_attributes.rb"
end
