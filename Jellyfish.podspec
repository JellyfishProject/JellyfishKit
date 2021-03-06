Pod::Spec.new do |s|
  s.name         = "Jellyfish"
  s.version      = "0.0.4"
  s.summary      = "API Blueprint mocking in Swift"
  s.description  = <<-DESC
    Jellyfish is an API Blueprint Parser with stubbing written in Swift
  DESC
  s.homepage     = "https://github.com/JellyfishProject/JellyfishKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Yeung Yiu Hung" => "hkclex@gmail.com" }
  s.social_media_url   = "https://twitter.com/darkcl_dev"
  s.swift_version = "3.2"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/JellyfishProject/JellyfishKit.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*.{h,m,swift}", "ext/**/*.{h,m,swift}"
  s.frameworks  = "Foundation", "JavaScriptCore"
  s.resources = "Sources/Jellyfish/Wrapper/drafter.js"
end
