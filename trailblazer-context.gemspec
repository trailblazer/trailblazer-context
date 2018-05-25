lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trailblazer/context/version'

Gem::Specification.new do |spec|
  spec.name          = "trailblazer-context"
  spec.version       = Trailblazer::Context::VERSION
  spec.authors       = ["Nick Sutterer"]
  spec.email         = ["apotonick@gmail.com"]

  spec.summary       = %q{Argument-specific data structures for Trailblazer.}
  spec.description   = %q{Argument-specific data structures for Trailblazer such as Context, Option and ContainerChain.}
  spec.homepage      = "http://trailblazer.to/gems/workflow"
  spec.license      = ["LGPL-3.0"]

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^test/})
  end
  spec.test_files    = `git ls-files -z test`.split("\x0")

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.required_ruby_version = '>= 2.0.0'
end
