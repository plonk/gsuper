# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gsuper/version'

Gem::Specification.new do |spec|
  spec.name          = "gsuper"
  spec.version       = GSuper::VERSION
  spec.authors       = ["Yoteichi"]
  spec.email         = ["plonk@piano.email.ne.jp"]

  spec.summary       = %q{program to superimpose text on screen}
  spec.description   = %q{program superimpose text on screen}
  spec.homepage      = "https://github.com/plonk/gsuper/"
  spec.licenses      = "GPL-2"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_dependency "gtk2", "~> 3.0.7"
  spec.add_dependency "toml-rb", "~> 0.3.12"
end
