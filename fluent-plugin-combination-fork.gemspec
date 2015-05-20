$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-combination-fork"
  gem.version     = "0.0.1"
  gem.authors     = ["Masayuki DOI"]
  gem.email       = "dotquasar@gmail.com"
  gem.homepage    = "https://github.com/mdoi/fluent-plugin-combination-fork"
  gem.description = "Fork output by combination values for fluentd"
  gem.summary     = "Fork output by combination values for fluentd"
  gem.licenses    = ["MIT"]

  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_development_dependency "rake"
end
