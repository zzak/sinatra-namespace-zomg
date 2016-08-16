Gem::Specification.new do |spec|
  spec.name           = "sinatra-namespace"
  spec.version        = "2.0.0"
  spec.description    = "Add namespaces to Sinatra."
  spec.summary        = "You can use namespaces in Sinatra!"

  spec.authors        = ["zzak"]
  spec.email          = "mail@zzak.io"
  spec.files          = `git ls-files`.split("\n")
  spec.homepage       = "https://github.com/zzak/#{spec.name}"
  spec.require_paths  = ["lib"]

  spec.add_dependency "sinatra"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec"
end
