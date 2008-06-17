Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "mollom"
    s.version   =   "0.1.3"
    s.rubyforge_project = "mollom"
    s.author    =   "Jan De Poorter"
    s.email     =   "mollom@openminds.be"
    s.homepage   =   "mollom.rubyforge.com"
    s.summary   =   "Ruby class for easy interfacing with the mollom.com open API for spam detection and content quality assesment."
    s.files     =   FileList['lib/**/*'].to_a
    s.require_path  =   "lib"
    s.test_files = FileList["test/*.rb"].to_a
    s.has_rdoc  =   true
    s.extra_rdoc_files  =   ["README.rdoc"]
end


