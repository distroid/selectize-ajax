# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'selectize/ajax/version'

Gem::Specification.new do |spec|
  spec.name          = 'selectize-ajax'
  spec.version       = Selectize::Ajax::VERSION
  spec.authors       = ['Ryabov Ruslan']
  spec.email         = ['diserve.it@gmail.com']

  spec.summary       = %q{Useful selectize form control.}
  spec.description   = %q{Useful selectize form control with autocomplete, create and edit items by ajax.}
  spec.homepage      = 'https://github.com/distroid/selectize-ajax'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.6', '< 3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rake', '~> 12'

  spec.add_dependency('coffee-rails', '~> 5.0')
end
