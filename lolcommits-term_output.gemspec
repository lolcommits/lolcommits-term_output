lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lolcommits/term_output/version'

Gem::Specification.new do |spec|
  spec.name        = "lolcommits-term_output"
  spec.version     = Lolcommits::TermOutput::VERSION
  spec.authors     = ["Matthew Hutchinson"]
  spec.email       = ["matt@hiddenloop.com"]
  spec.summary     = "Display lolcommits within your iTerm terminal"
  spec.homepage    = "https://github.com/lolcommits/lolcommits-term_output"
  spec.license     = "LGPL-3.0"
  spec.description = "Display lolcommits within your iTerm terminal"

  spec.metadata = {
    "homepage_uri"      => "https://github.com/lolcommits/lolcommits-term_output",
    "changelog_uri"     => "https://github.com/lolcommits/lolcommits-term_output/blob/master/CHANGELOG.md",
    "source_code_uri"   => "https://github.com/lolcommits/lolcommits-term_output",
    "bug_tracker_uri"   => "https://github.com/lolcommits/lolcommits-term_output/issues",
    "allowed_push_host" => "https://rubygems.org"
  }

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(assets|test|features)/}) }
  spec.test_files    = `git ls-files -- {test,features}/*`.split("\n")
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3"

  spec.add_runtime_dependency "lolcommits", "0.16.1"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "simplecov"
end
