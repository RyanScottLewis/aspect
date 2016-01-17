require "pathname"

Gem::Specification.new do |spec|
  # Variables
  spec.summary = "A small collection of useful classes, modules, and mixins for plain old Ruby objects."
  spec.license = "MIT"

  # Dependencies
  spec.add_dependency "version", "~> 1.0.0"

  # Pragmatically set variables and constants
  spec.author        = "Ryan Scott Lewis"
  spec.email         = "ryan@rynet.us"
  spec.homepage      = "http://github.com/RyanScottLewis/#{spec.name}"
  spec.version       = Pathname.glob("VERSION*").first.read rescue "0.0.0"
  spec.description   = spec.summary
  spec.name          = Pathname.new(__FILE__).basename(".gemspec").to_s
  spec.require_paths = ["lib"]
  spec.files         = Dir["{Rakefile,Gemfile,README*,VERSION,LICENSE,*.gemspec,{lib,bin,examples,spec,test}/**/*}"]
  spec.test_files    = Dir["{examples,spec,test}/**/*"]
end
