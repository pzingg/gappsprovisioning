# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gappsprovisioning}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["pzingg@kentfieldschools.org"]
  s.date = %q{2009-07-09}
  s.description = %q{Provisioning API v2.0 Ruby client library for Google Apps.  Based on GData API v2.0, with Groups API changes * running even behind authenticated http proxies * using REXML (no extra module dependency)  Author: Jerome Bousquie  http://personnel.univ-reunion.fr/bousquie/}
  s.email = ["FIXME email"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "lib/gappsprovisioning.rb", "lib/gappsprovisioning/connection.rb", "lib/gappsprovisioning/exceptions.rb", "lib/gappsprovisioning/provisioningapi.rb", "script/console", "script/destroy", "script/generate", "test/test_gappsprovisioning.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{Gemified version of Google Code project at}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{gappsprovisioning}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Provisioning API v2.0 Ruby client library for Google Apps}
  s.test_files = ["test/test_gappsprovisioning.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<newgem>, [">= 1.1.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<newgem>, [">= 1.1.0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.1.0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
