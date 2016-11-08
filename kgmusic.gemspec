# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kgmusic/version'

Gem::Specification.new do |spec|
  spec.name          = "kgmusic"
  spec.version       = KgMusic::VERSION
  spec.authors       = ["vitvegl"]
  spec.email         = ["vitvelg@gmail.com"]

  spec.summary       = "find and download music albums on kibergrad.fm"
  spec.description   = "find and download music albums on kibergrad.fm"
  spec.license       = "GPL-3.0"
  spec.homepage      = "https://github.com/vitvegl/kgmusic.git"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.executables << 'kgget'

  #spec.add_runtime_dependency "unicode_utils", "1.4.0"
  #spec.add_runtime_dependency "rest-client", "~> 1.8", ">= 1.8.0"
  spec.add_runtime_dependency "curb", "~> 0.9", ">= 0.9.3"
  spec.add_runtime_dependency "nokogiri", "~> 1.6", ">= 1.6.0"
  #spec.add_runtime_dependency "progressbar", "0.21.0"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
