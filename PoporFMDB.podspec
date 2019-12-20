#
# Be sure to run `pod lib lint PoporFMDB.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'PoporFMDB'
    s.version          = '1.03'
    s.summary          = 'Init FMDB table; update db table column; simple sql tool;'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    #  s.description      = <<-DESC
    #TODO: Add long description of the pod here.
    #                       DESC
    
    s.homepage         = 'https://github.com/popor/PoporFMDB'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'popor' => '908891024@qq.com' }
    s.source           = { :git => 'https://github.com/popor/PoporFMDB.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.requires_arc = true
    
    s.ios.frameworks         = 'Foundation'
    s.tvos.frameworks        = 'Foundation'
    s.osx.frameworks         = 'Foundation'
    
    s.ios.deployment_target  = '8.0' # minimum SDK with autolayout
    s.osx.deployment_target  = '10.10' # minimum SDK with autolayout
    s.tvos.deployment_target = '9.0' # minimum SDK with autolayout
    
    
    s.source_files = 'PoporFMDB/Classes/*.{h,m}'
    
    s.dependency 'FMDB'
    s.dependency 'PoporFoundation/NSString'
    
end
