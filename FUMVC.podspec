#
# Be sure to run `pod lib lint FUMVC.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FUMVC'
  s.version          = '0.1.0'
  s.summary          = 'iOS Fundamentals of MVC'
	s.swift_version 	 = '4.2'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
		A library to demonstrate and provide common architectural abstractions in a very lean way. Initially focuses on Core Data, specifically a Model Controller using generics to reduce boilerplate code in Core Data CRUD operations.
                       DESC

  s.homepage         = 'https://github.com/thepost/FUMVC'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mike Post' => 'mikepost@live.com' }
  s.source           = { :git => 'https://github.com/thepost/FUMVC.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
	s.platform     					= :ios, '11.0'

  s.source_files = 'FUMVC/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FUMVC' => ['FUMVC/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'CoreData'
  # s.dependency 'AFNetworking', '~> 2.3'
end
