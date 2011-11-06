# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ycode/version"

Gem::Specification.new do |s|
  s.name        = "ycode"
  s.version     = Ycode::VERSION
  s.authors     = ["Toby Hinloopen"]
  s.email       = ["toby@kutcomputers.nl"]
  s.homepage    = "http://y-ch.at/"
  s.summary     = %q{Y-Code gem}
  s.description = %q{Custom-markup parser for http://y-ch.at/}

  s.rubyforge_project = "ycode"
	s.add_dependency "will_scan_string", "~> 0.0.2"
	s.add_development_dependency "rspec", "~> 2.6"
	s.add_dependency "activesupport", "~> 3.0.9"
	s.add_dependency "i18n", "~> 0.5.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
