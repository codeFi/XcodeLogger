Pod::Spec.new do |s|

  s.name         = "XcodeLogger"
  s.version      = "1.2.1"
  s.summary      = "Simple, fast, colorful, flexible and customizable NSLog replacement."
  s.description  = <<-DESC
                   Xcode Logger is a fast (up to *6x times faster than NSLog and up to 4x times faster than CocoaLumberjack), extremely simple to use, very flexible library which provides scheme-based, customizable and theme based, colorful and filterable NSLog replacements.

*based on synchronous tests running on main thread, comparing XLog_NH vs NSLog vs DDLogVerbose, average operation time after 5 runs with 5000 iterations per test, per run on a MacBook Pro Retina. Xcode Logger had colors enabled for every level while for CocoaLumberjack the colors were disabled.
                   DESC

  s.homepage     = "https://github.com/codeFi/XcodeLogger"
  s.screenshots  = "http://i57.tinypic.com/2it544n.jpg", "http://i61.tinypic.com/24qv4n5.png", "http://i57.tinypic.com/9j0snd.png", "http://i61.tinypic.com/mkepnl.png", "http://i58.tinypic.com/33dbkfl.png", "http://i60.tinypic.com/ofygra.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Razvan Tanase" => "razvan@codebringers.com" }
  s.social_media_url   = "http://twitter.com/razvan_tanase"
  s.ios.deployment_target = "5.0"
  s.osx.deployment_target = "10.7"
  s.source       = {
  					 :git => "https://github.com/codeFi/XcodeLogger.git",
  					 :tag => "1.2.1"
  				   }

  s.source_files  = "XcodeLogger/**/*.{h,m}"
  s.resources = "XcodeLogger/**/*.plist"

end
