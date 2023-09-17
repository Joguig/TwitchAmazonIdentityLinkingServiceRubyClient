# coding: utf-8
lib = File.expand_path('../lib/TwitchAmazonIdentityLinkingServiceRubyClient/version,', __FILE__)


Gem::Specification.new do |spec|
  spec.name          = "TwitchAmazonIdentityLinkingServiceRubyClient"
  spec.version       = TwitchAmazonIdentityLinkingServiceRubyClient::VERSION
  spec.authors       = ["Dai"]
  spec.email         = ["daiwe@amazon.com"]

  spec.summary       = %q{summary}
  spec.description   = %q{description}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  #spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.files << "TwitchAmazonIdentityLinkingServiceRubyClient.gemspec"
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("lib/**/*.pem")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
