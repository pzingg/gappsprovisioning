# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gappsprovisioning}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jerome Bousquie", "Peter Zingg"]
  s.date = %q{2009-07-29}
  s.description = %q{Google Apps Provisioning API v2.0 Ruby client library.  Based on GData API v2.0, with Groups API changes.}
  s.email = %q{peter.zingg@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "README.rdoc",
     "Rakefile",
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
  s.homepage = %q{http://github.com/pzingg/gappsprovisioning}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{gappsprovisioning}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Google Apps Provisioning API v2.0 Ruby client library}
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
