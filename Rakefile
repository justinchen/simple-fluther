require 'jeweler'

task :default => :build

Jeweler::Tasks.new do |s|
  s.name = 'simple-fluther'
  s.summary = 'Modified version of original fluther gem for integrating into Rails.'
  s.email = 'justin@menuism.com'
  s.homepage = 'http://github.com/justinchen/simple-fluther'
  s.description = 'Ruby interface to the Fluther discussion system'
  s.authors = ['Justin Chen']
  s.files = FileList[ 
     'MIT-LICENSE',
     'README.textile',
      'lib/**/*'
  ]
  s.add_dependency 'em-http-request'
end
Jeweler::GemcutterTasks.new
