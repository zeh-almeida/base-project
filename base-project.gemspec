
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'base/project/version'

Gem::Specification.new do |spec|
  spec.name          = 'base-project'
  spec.version       = Base::Project::VERSION
  spec.authors       = ['José Ricardo Carvalho Prado de Almeida']
  spec.email         = ['zehpavora@gmail.com']

  spec.summary       = 'Base definitions for a project. Contains lots of usable reusables'
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.3.0'

  spec.add_development_dependency 'bundler', '~> 1.16.a'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'devise'
  spec.add_development_dependency 'cpf_cnpj'
  spec.add_development_dependency 'validators'
  spec.add_development_dependency 'attribute_normalizer'
  spec.add_development_dependency 'money'
  spec.add_development_dependency 'money-rails'
  spec.add_development_dependency 'nested_form'
  spec.add_development_dependency 'simple_form'
  spec.add_development_dependency 'i18n_generators'
  spec.add_development_dependency 'paperclip'
end
