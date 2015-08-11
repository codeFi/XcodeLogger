Pod::Spec.new do |s|

  s.name         = "XcodeLogger"
  s.version      = "1.0.1"
  s.summary      = "Simple, fast, colorful, flexible and customizable NSLog replacement."
  s.description  = <<-DESC
                   Xcode Logger is a fast (up to *35x times faster than NSLog), simple to use, flexible library which 
                   provides colorful and scheme-based NSLog replacements using the Xcode Colors plugin for Xcode IDE which 
                   works great in multi-threaded environments.

                   *based on tests comparing NSLog vs XLog's No Header level, average operation time after 5 runs with 
                   5000 iterations per run on a MacBook Pro Retina. 
                   DESC

  s.homepage     = "https://github.com/codeFi/XcodeLogger"
  s.screenshots  = "http://i58.tinypic.com/6700f4.png", "http://i58.tinypic.com/jsh9vm.jpg"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Razvan Tanase" => "razvan@codebringers.com" }
  s.social_media_url   = "http://twitter.com/razvan_tanase"
  s.ios.deployment_target = "5.0"
  s.osx.deployment_target = "10.7"
  s.source       = { 
  					 :git => "https://github.com/codeFi/XcodeLogger.git", 
  					 :tag => "1.0.1"
  				   }

  s.source_files  = "XcodeLogger/**/*.{h,m}"


end
