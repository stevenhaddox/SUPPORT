# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'SUPPORT/version'

Gem::Specification.new do |spec|
  spec.name          = "SUPPORT"
  spec.version       = SUPPORT::VERSION
  spec.authors       = ["Steven Haddox"]
  spec.email         = ["steven@haddox.us"]
  spec.description   = %q{SUPPORT: Setting Up & Provisioning Pragmatic OSS Ruby Technologies}
  spec.summary       = %q{SUPPORT provides a CLI to select & download OSS code, dependencies, and chef cookbooks to stand up a standalone Ruby "support" server.}
  spec.homepage      = "https://github.com/stevenhaddox/SUPPORT"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.bindir        = "bin"
  spec.executables   = "support"

  spec.add_runtime_dependency("gli", "~> 2.5")

  spec.add_development_dependency("aruba", "~> 0.5")
  spec.add_development_dependency("awesome_print", "~> 1.1")
  spec.add_development_dependency("bundler", "~> 1.3")
  spec.add_development_dependency("capybara", "~> 2.0")
  spec.add_development_dependency("cucumber", "~> 1.2")
  spec.add_development_dependency("rake", "~> 10.0")
  spec.add_development_dependency("rspec", "~> 2.4")
end
