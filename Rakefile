require 'rubygems'
require 'rake/rdoctask'
require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "bradleypriest-mollom"
    gemspec.summary = "Ruby class for easy interfacing with the mollom.com open API for spam detection and content quality assesment."
    gemspec.description = "Ruby class for easy interfacing with the mollom.com open API for spam detection and content quality assesment."
    gemspec.email = "mollom@openminds.be"
    gemspec.homepage = "http://mollom.rubyforge.com"
    gemspec.authors = ["Jan De Poorter"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
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
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
}
