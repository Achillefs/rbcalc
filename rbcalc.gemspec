# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbcalc'

Gem::Specification.new do |spec|
  spec.name          = "rbcalc"
  spec.version       = Rbcalc::VERSION
  spec.authors       = ["Achilles Charmpilas"]
  spec.email         = ["ac@humbuckercode.co.uk"]
  spec.description   = %q{Ruby bindings for Piotr Beling's Bridge Calculator}
  spec.summary       = %q{Ruby bindings for Piotr Beling's Bridge Calculator}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_dependency "RubyInline", "~> 3.12"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fuubar"
end
