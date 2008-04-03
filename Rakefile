require 'rubygems'
require 'rake/rdoctask'
require 'rake/testtask'

Gem::manage_gems

require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "mollom"
    s.version   =   "0.1"
    s.author    =   "Jan De Poorter"
    s.email     =   "mollom@openminds.be"
    s.homepage   =   "mollom.rubyforge.com"
    s.summary   =   "Ruby class for easy interfacing with the mollom.com open API for spam detection and content quality assesment."
    s.files     =   FileList['lib/**/*'].to_a
    s.require_path  =   "lib"
    s.test_files = FileList["test/*.rb"].to_a
    s.has_rdoc  =   true
    s.extra_rdoc_files  =   ["README"]
end
 
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

Rake::RDocTask.new { |rdoc|
  rdoc.rdoc_dir = 'docs'
  rdoc.title    = "Mollom -- Ruby class for easy interfacing with the mollom.com open API for spam detection and content quality assesment."
  rdoc.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
}
