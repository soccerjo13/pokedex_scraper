lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pokedex_scraper/version"

Gem::Specification.new do |spec|
  spec.name          = "pokedex_scraper"
  spec.version       = PokedexScraper::VERSION
  spec.authors       = ["Jo Roe"]
  spec.email         = ["soccerjo@gmail.com"]

  spec.summary       = %q{scrape thesilphroad.com}

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'httparty'
  spec.add_dependency 'nokogiri'

  spec.add_development_dependency "bundler"#, "~> 2.0"
  spec.add_development_dependency "rake"#, "~> 10.0"
  spec.add_development_dependency "rspec"#, "~> 3.0"
  spec.add_development_dependency "pry"
end
