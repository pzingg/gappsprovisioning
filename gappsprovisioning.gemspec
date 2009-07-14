# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.version = "0.1.0"

  s.name = %q{gappsprovisioning}
  s.rubyforge_project = %q{gappsprovisioning}
  s.homepage = %q{http://github.com/pzingg/gappsprovisioning}
  s.authors = ["Jerome Bousquie", "Peter Zingg"]
  s.email = %q{peter.zingg@gmail.com}
  s.summary = %q{Google Apps Provisioning API v2.0 Ruby client library}
  s.description = %q{Google Apps Provisioning API v2.0 Ruby client library.  Based on GData API v2.0, with Groups API changes.}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.date = %q{2009-07-14}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    ".gitignore",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "VERSION.yml",
     "gappsprovisioning.gemspec",
     "lib/gappsprovisioning.rb",
     "lib/gappsprovisioning/connection.rb",
     "lib/gappsprovisioning/exceptions.rb",
     "lib/gappsprovisioning/provisioningapi.rb",
     "test/test_gappsprovisioning.rb",
     "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.test_files = [
    "test/test_gappsprovisioning.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
