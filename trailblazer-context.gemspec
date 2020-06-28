lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "trailblazer/context/version"

Gem::Specification.new do |spec|
  spec.name          = "trailblazer-context"
  spec.version       = Trailblazer::Context::VERSION
  spec.authors       = ["Nick Sutterer"]
  spec.email         = ["apotonick@gmail.com"]

  spec.summary       = "Argument-specific data structures for Trailblazer."
  spec.description   = "Argument-specific data structures for Trailblazer such as Context, Option and ContainerChain."
  spec.homepage      = "http://trailblazer.to/gems/workflow"
  spec.licenses      = ["MIT"]

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r(^test/))
  end
  spec.test_files    = `git ls-files -z test`.split("\x0")

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"

  # maybe we could remove this?
  spec.required_ruby_version = ">= 2.1.0"
end
