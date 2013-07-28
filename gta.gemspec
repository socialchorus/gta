# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gta/version'

Gem::Specification.new do |spec|
  spec.name          = "gta"
  spec.version       = GTA::VERSION
  spec.authors       = ["socialchorus", "Kane Baccigalupi"]
  spec.email         = ["developers@socialchorus.com"]
  spec.description   = %q{GTA: the Git Transit Authority - A git based deploy tool for moving code from stage to stage.}
  spec.summary       = %q{GTA: the Git Transit Authority - A git based deploy tool for moving code from stage to stage.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
