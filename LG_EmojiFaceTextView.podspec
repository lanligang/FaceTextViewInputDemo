Pod::Spec.new do |s|

  s.name     = 'LG_EmojiTextView'

  s.version  = '0.0.1'

  s.license  = { :type => 'MIT' }

  s.summary  = '饼图、折线图、柱状图'

  s.description = <<-DESC
                    描述内容
                   DESC

  s.homepage = 'https://github.com/lanligang/FaceTextViewInputDemo'

  s.authors  = { 'LenSky' => 1176281703@qq.com' }

  s.source   = { :git => 'https://github.com/lanligang/FaceTextViewInputDemo.git', :tag => s.version }

  s.source_files = 'EmojiFaceTextView/FaceTxtViewManager/**/*.{h,m}'
  s.resource     = 'FaceTxtViewManager/source/face_image.bundle'
  s.resource     = 'FaceTxtViewManager/source/face_array.plist'
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.ios.frameworks = ['UIKit', 'CoreGraphics', 'Foundation']
end