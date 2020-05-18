Pod::Spec.new do |s|

  s.name     = 'FaceTxtViewManager'

  s.version  = '0.0.1'

  s.license  = { :type => 'MIT' }

  s.summary  = '表情输入框可自定义'

  s.description = <<-DESC
                    FaceTxtViewManager
                    表情输入框可自定义
                   DESC

  s.homepage = 'https://github.com/lanligang/FaceTextViewInputDemo'

   s.authors  = { 'LenSky' => 'lslanligang@sina.com' }

  s.source   = { :git => 'https://github.com/lanligang/FaceTextViewInputDemo.git', :tag => s.version }

  s.source_files = 'EmojiFaceTextView/FaceTxtViewManager/**/*.{h,m}'
  s.resource     = 'FaceTxtViewManager/source/face_image.bundle'
  s.resource     = 'FaceTxtViewManager/source/face_array.plist'
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.ios.frameworks = ['UIKit', 'CoreGraphics', 'Foundation']
end