platform :ios, '17.0'

workspace 'CoreClaw'

target 'CoreClaw' do
  # YAML 解析（SkillLoader 用于解析 SKILL.md frontmatter）
  pod 'Yams'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'

      # Static-library pod targets do not contain an app bundle in which Swift
      # runtime libraries could be embedded. Leaving this enabled makes Xcode
      # emit a warning on every device build.
      if target.respond_to?(:product_type) && target.product_type == 'com.apple.product-type.library.static'
        config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
      end
    end
  end

  # With Xcode's separately installed Metal toolchain, TOOLCHAIN_DIR can point
  # at the Metal compiler bundle rather than XcodeDefault.xctoolchain. The
  # Swift library path CocoaPods derives from it does not exist and produces a
  # linker warning. Xcode already supplies the correct Swift runtime paths.
  installer.aggregate_targets.each do |aggregate_target|
    aggregate_target.xcconfigs.each do |configuration_name, xcconfig|
      search_paths = xcconfig.attributes['LIBRARY_SEARCH_PATHS']
      next unless search_paths

      xcconfig.attributes['LIBRARY_SEARCH_PATHS'] = search_paths.gsub(
        /\s*"\$\{TOOLCHAIN_DIR\}\/usr\/lib\/swift\/\$\{PLATFORM_NAME\}"/,
        ''
      )
      xcconfig.save_as(aggregate_target.xcconfig_path(configuration_name))
    end
  end
end
