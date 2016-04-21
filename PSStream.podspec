#
# Be sure to run `pod lib lint PSStream.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PSStream"
  s.version          = "1.0.0"
  s.summary          = "A short description of PSStream."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  集合流式处理框架
                       DESC

  s.homepage         = "https://github.com/Poi-Son/PSStream"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "PoiSon" => "git@yerl.cn" }
  s.source           = { :git => "https://github.com/Poi-Son/PSStream.git", :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'PSStream/Classes/**/*'
  s.resource_bundles = {
    'PSStream' => ['PSStream/Assets/*.png']
  }
end
