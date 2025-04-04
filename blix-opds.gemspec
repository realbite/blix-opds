require_relative 'lib/blix/opds/version'

Gem::Specification.new do |spec|
  spec.name          = "blix-opds"
  spec.version       = Blix::OPDS::VERSION
  spec.authors       = ["Clive Andrews"]
  spec.email         = ["pacman@realitybites.eu"]

  spec.summary       = %q{OPDS catalog generator for Blix}
  spec.description   = %q{A library for generating OPDS (Open Publication Distribution System) catalogs in Blix applications}
  spec.homepage      = "https://github.com/yourusername/blix-opds"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.files = Dir.glob(['lib/**/*.rb', 'README.md'])
  spec.extra_rdoc_files = ['README.md']
  spec.require_paths = ["lib"]


  spec.add_dependency "nokogiri", "~> 1.10"
  spec.add_development_dependency "rspec", "~> 3.0"
end