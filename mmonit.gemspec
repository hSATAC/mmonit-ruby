# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "mmonit/version"

Gem::Specification.new do |gem|
	gem.authors = ['hSATAC']
	gem.email = ['hsatac@gmail.com']
	gem.homepage = 'http://github.com/hSATAC/mmonit-ruby'
	gem.summary = 'Ruby interface to M/Monit, support mmonit v3'
	gem.description = gem.summary
	gem.name = 'mmonit-client'
	gem.files = `git ls-files`.split("\n")
	gem.require_paths = ['lib']
	gem.version = MMonit::VERSION
end
