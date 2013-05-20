Gem::Specification.new do |s|
  s.name        = 'lazy_stream'
  s.version     = '0.5.2'
  s.date        = '2013-05-21'
  s.summary     = 'lazy_stream'
  s.description = 'Ruby infinite lazy stream'
  s.authors     = ['Mingmin Xie']
  s.email       = 'melvinxie@gmail.com'
  s.files       = ['lib/lazy_stream.rb']
  s.homepage    = 'https://github.com/melvinxie/lazy_stream'
  s.license     = 'MIT'
  s.test_files  = Dir.glob("{spec}/**/*.rb")
  s.add_development_dependency 'rspec'
end
