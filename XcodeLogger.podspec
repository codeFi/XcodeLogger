Pod::Spec.new do |s|

  s.name         = "XcodeLogger"
  s.version      = "2.0.0"
  s.summary      = "Modern Apple-platform logging with Unified Logging and optional ANSI debug output."
  s.description  = <<-DESC
                   XcodeLogger 2 is a Swift-first rewrite for current Apple platforms.
                   It uses Unified Logging as the primary sink, supports explicit configuration,
                   and can emit ANSI-colored debug output when the active console preserves escapes.
                   DESC

  s.homepage     = "https://github.com/codeFi/XcodeLogger"
  s.screenshots  = "http://i57.tinypic.com/2it544n.jpg", "http://i61.tinypic.com/24qv4n5.png", "http://i57.tinypic.com/9j0snd.png", "http://i61.tinypic.com/mkepnl.png", "http://i58.tinypic.com/33dbkfl.png", "http://i60.tinypic.com/ofygra.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Razvan Tanase" => "razvan@codebringers.com" }
  s.social_media_url   = "http://twitter.com/razvan_tanase"
  s.swift_version = "6.0"
  s.ios.deployment_target = "17.0"
  s.osx.deployment_target = "14.0"
  s.tvos.deployment_target = "17.0"
  s.watchos.deployment_target = "10.0"
  s.source       = {
  					 :git => "https://github.com/codeFi/XcodeLogger.git",
  					 :tag => "2.0.0"
  				   }

  s.source_files  = "Sources/XcodeLogger/**/*.swift"

end
