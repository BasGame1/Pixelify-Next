### Version 4.0
-INIT PIxelify Next
### Version 4.1
-Fix bugs
### Version 4.4
-Add Pixelify Launcher
### Version 4.4.1
-Fix bugs
### Version 4.5
-Added Pixel Journal app and Pixel Studio app (they crash on some devices)
### Version 4.6
-Removed Pixel Studio, added gemini bootaniamtion and introduce Air Drop Quick Share (Quick share extension)
### Version 5.0
-Add webui to control the module
-Add KSUn Next banner
-Update the zygisk code
-Add update json
-Update zygisk code
-Add global spoofing
-Add sim card us spoofing
-Fix bugs
    - Pixel launcher pausing the installation
    - Pixel launcher asking a y or n question
    - Bootanimation not appearing
    - Journal not installing
    - System files not unpacking
    - Zygisk code not being compatible

### Version 5.1
 - Recode apk installer script
 - Fix bugs
   - Mosey not installing
   
### Version 5.2
 - Drop mosey support (it was not working correctly)
 - Fix bugs
   - Syntax errors causing the installation to fail
   
### Version 5.8
 - Drop flag system for props and spoofing based system
 - Fix pixel Launcher on all qpr android versions
 - Add AiCore for dialer features
 
### Version 6.0
 - Rework all gradle and build system
 - Bug fixes
   - Fix WebUI script errors

### Version 6.0.1
 - Bug Fixes
   - Add a forgotten quote :)

### Version 6.1
 - Add ABI argument to installAPK
 - Bug fixes
   - Gemini bootaniamtion not appearing
   - Aicore not installing on some arm64 and arm32 devices
   - Syntax errors in customize

### Version 6.2
- Fix pixel launcher not being deleted
- Downgrade to zygisk ApI v2 to fix compatibility errors

### Version 7.0
 - Upgrade Zygisk engine to API v4 with multi-ABI detection and bootloop protection
 - Add WebUI per-app model override selector with quick presets
 - Add Phenotype microhooks flag patcher for Call Screen, Hold for Me, Call Recording, AICore, and PSI without LSPosed
 - Add WebUI Phenotype Flags status monitor screen with real-time verification and re-patch controls
 - Add LineageOS 23.2 warning prompt during installation
 - Add live 2-boot rotation recovery logger (`live-logging-boot1.log` & `live-logging-boot2.log`)
 - Add Magisk/KernelSU auto-download support via update.json
 - Codebase cleanup, fixing syntax errors and corrupted terminal escape sequences
 - Add pretier readme
