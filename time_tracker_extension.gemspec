$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "time_tracker_extension/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "time_tracker_extension"
  spec.version     = TimeTrackerExtension::VERSION
  spec.authors     = ["Andres Sild"]
  spec.email       = ["x3enos@gmail.com"]
  spec.homepage    = "http://andres-sild.com/"
  spec.summary     = "Time Tracker extension"
  spec.description = "There are some additional features for time tracker"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.4.3"
  spec.add_dependency "telegram-bot"
  spec.add_dependency "telegram-bot-types"


  spec.add_development_dependency "pg"
  spec.add_development_dependency "jbuilder"
  spec.add_development_dependency "pundit"

  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "factory_bot_rails"
  spec.add_development_dependency "faker"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "shoulda-matchers"
  spec.add_development_dependency "pundit-matchers"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "bcrypt"
  spec.add_dependency "pry-rails"
end
