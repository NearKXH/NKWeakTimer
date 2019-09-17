Pod::Spec.new do |s|
  s.name         = "NKWeakTimer"
  s.version      = "1.0.0"
  s.summary      = "A delightful iOS and OS X Weak Timer."
  s.description  = <<-DESC
`NKCWeakTimer` can be used as `NSTimer`, but do not retain Target.
`NKCWeakTimer` is implemented by `GCD`, and all founction as `NSTimer`.
                   DESC
  s.homepage     = "https://github.com/NearKXH/NKCWeakTimer"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Near" => "near.kongxh@gmail.com" }
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/NearKXH/NKCWeakTimer.git", :tag => s.version.to_s }
  s.source_files  = "NKCWeakTimer/**/*"
  s.requires_arc = true

end
