# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ansiterm/version'

Gem::Specification.new do |spec|
  spec.name          = "ansiterm"
  spec.version       = AnsiTerm::VERSION
  spec.authors       = ["Vidar Hokstad"]
  spec.email         = ["vidar@hokstad.com"]

  spec.summary       = %q{ANSI/VT102 terminal output with windowing}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/vidarh/ansiterm"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
