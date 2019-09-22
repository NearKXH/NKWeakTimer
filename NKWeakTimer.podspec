Pod::Spec.new do |s|
  s.name         = "NKWeakTimer"
  s.version      = "1.0.0"
  s.summary      = "A delightful iOS and OS X Weak Timer."
  s.description  = <<-DESC
	NKWeakTimer can be used as `NSTimer`, but do not retain Target.
	It is implemented by `GCD`, and all features is similar to NSTimer.
                   DESC
  s.homepage     = "https://github.com/NearKXH/NKWeakTimer"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Near" => "near.kongxh@gmail.com" }
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/NearKXH/NKWeakTimer.git", :tag => s.version.to_s }
  s.source_files  = "NKWeakTimer/**/*"
  s.requires_arc = true

end
