<div align=center>
    <img src="https://capsule-render.vercel.app/api?type=venom&height=300&color=gradient&text=Pixelify%20Next&fontColor=00A3A3&textBg=false" alt="Pixelify Next Animated Title" /> 
    
![Platform](https://img.shields.io/badge/Android-green?style=flat-square&logo=android)
![Static Badge](https://img.shields.io/badge/Bash-white?logo=GNU%20Bash)
![Static Badge](https://img.shields.io/badge/C++-blue?logo=c)
![Static Badge](https://img.shields.io/badge/magisk-black?logo=magisk)
![Static Badge](https://img.shields.io/badge/Gradle-red?logo=gradle)
<p>
A Root module to give Pixel Stuff to all phones!
</div>

---

## Bugs
- **Google Flags [server side changes]**
- **On some devices or roms sudden bootloop can be seen with pixel launcher [Unkown cause]**
---
## Requirements
- **Supported Android Versions: Android 7.0 to Android 16**
- **ARM64 or ARM32 device**
- **Volume Keys (optional)**
- **Internet for downloading NGA Resources, Pixel Livewallpaper, Device Personalization Services & Pixel Launcher**
- **Magisk v24 or above from Pixelify v2+**
- **Zygisk (Recommended but not mandatory, needed for spoofing functions)**
- **NOTE: Flash the module zip file in the Magisk Manager app only; flashing the module in TWRP or any other recovery won't work.**
---
### Unsupported Roms
- **Realme Ui (Android 14)**, Oxygen Os (Android 14), axion Os (Android 16) will not work. It will bootloop rom after reboot. only way is to fix it by factory reset.
- **LineageOS 23.2 (android 16)**: MAY contain bugs or bootloops but is not guaranteed, its luck!
- **OneUI (all android version)**: Most of the features like pixel launcher or bootanimation arent compatible, recommended use of the [submodules](https://github.com/BasGame1/Pixelify-NEXT-Submodules)
---
### Tested Roms
- LineageOS (Android 15 & 16)
- Stock android (android 16 & 17)
---
### To Build
- Use `build.sh` (linux, android, etc) or `build.bat` (windows) and select the version you want to build
- Use `build and flash.sh` (linux, android, etc) or `build and flash.sh` (windows) to build and flash it to the device connected via ADB
---
### Pixelify Submodules
- For installing just a specific feature, like pixel launcher or call screen, use [submodules](https://github.com/BasGame1/Pixelify-NEXT-Submodules)
---
## Instructions
- [Instructions file](installation.md)
---
## Changelog
- [Changelog file](changelog.md)
---
## Features
(They may not work depending on the device, bc some are server side, but report them if they dont work, u are adviced)
- Initial Size of module is low
- Open Source
- Works with most of Android version
- Uses Dynamic spoofing (Zygisk API v4) for only Google apps to prevent crashes and other issues
- Provides most of the Pixel exclusive features
- Installation of features is optional
- Supports (720p,1080p,1440p) Google bootanimation
- Gemini bootanimation
- Quick Share Air drop support [NEW, UNTESTED]
- Allows creation of backup of online Pixelify packages
- Also provides some unreleased Pixel Features
- Creates Google keyboard, Google app, Google Text to speech, Google Dialer as system app if not installed
- Dynamic Permission generation of apps installed by pixelify
- Config as well as Volume key installation
- Patches Phenotype microhooks for Call Screen, Hold for Me, Call Recording without LSPosed
- WebUI with status monitor, per-app model override selector, and Phenotype Flags status screen

### Pixel 7 & 8 Features Enabled
-   Pixel 6 & Pixel 7 Live Wallpapers*
-   Magic Eraser
-   Magic Editor
-   Audio Eraser
-   ProofRead
-   Google Dialer Direct Call (12+)
-   New At a Glance feature (12+ & Dec+ Patch) 
-   Google Quick Phrase*
-   Google Next Generation Assistant Typing (Next Generation Assistant Required)*
-   Personalized Speech Recognition
-   Call Caption Typing (12+)**
-   Live Captions different language

### Pixel 9 & 10 Features Enabled
- Pixel Studio**
- Pixel journal

### Other Features
-   Adaptive Charging (Google SystemUI)
-   Adaptive Connectivity (11+)
-   Adaptive Sound (11+)*
-   Call Captions (11+)(Depends on Rom)
-   Enables Nexus, Pixel, and Android One app support
-   Google Dialer Call Screening
-   Google Dialer Hold for me
-   Google Dialer Call Recording (Device depended for working)
-   Google Dialer Automatic Call Screening **
-   Google Duo features
-   Live captions (10+)
-   Next Generation Assistant* (10+)(Optional)
-   Now Playing Export* (Works only on Pixel Phone)
-   Pixel Device spoofing (Optional)
-   Pixel Launcher (Android 16)
-   Pixel Blue theme accent
-   Pixel bootanimation (Optional)
-   Pixel Live Wallpapers (Optional)
-   Unlimited Photos backup (Storage saver)
-   Unlimited Photos backup (original) (needs Zygisk and KSU/apach) **
<br>
* - Requires Spoofing to Pixel device
** - Crash/ not work on some devices
    
### Call Screening Supported languages other than English US <br>
- Italian (IT)
- Japanese (JP)
- Spain (ES)
- France (FR)
- Germany (DE)
  
---

## Contact (for errors or suggestions)
- [Group Chat](https://t.me/PixelifyNext)
- [Group Channel](https:/t.me/Pixelifychannel)
- [Github Issues](https://github.com/BasGame1/Pixelify-Next/issues)
  
---

## Contribute to project
- *All contributions are appreciated*
- Reporting bugs with logs
- Feature Requests
- Supporting other persons on issues or telegram (t.me/@basgame1)
- Creating pull request to enable new feature or code improvements
  
---

## Credits <3
- Google for creating these awesome features

- [Wikimedia](https://commons.wikimedia.org) For google icon
 
- [Tristan](https://t.me/@Tristan_xxxxx) For sending the Pixel Launcher files and Journal app
  
- [topjohnwu](https://github.com/topjohnwu) for Magisk
  
- [#TeamFiles](https://t.me/modulesrepo) for so many themed icons for Pixel Launcher android 12
  
- [Kdrag0n](https://github.com/kdrag0n) for SimpleDeviceConfig
  
- [Freak07](https://forum.xda-developers.com/m/freak07.3428502/) for Adaptive Sound
  
- [Pranav Pandey](https://forum.xda-developers.com/m/pranav-pandey.3962236/) for BreelWallpaper2020 Port
  
- [HuskyDG](https://github.com/HuskyDG) for intial Riru Port, Bootloop saver
  
- [Enzo Ariel](https://github.com/enzosanchezariel) for pixel launcher fix
    
- [Saitama](https://github.com/saitamasahil) Fixing Pixel Launcher crashes
    
- [Gapps Flag Leaks](https://t.me/GappsLeaks) AssembleDebug For some flags
    
- [Mewona](https://t.me/@TempMeow) For Pixel Launcher files
  
- Kevin (tg) for gemini bootanimation
  
- Android Port World & Amr Gamal Store (tg) for Pixel Launcher 7.1 overlays
   
- [SQlite Organization](https://www.sqlite.org/) for SQlite3 uncompiled files
  
- [UhExooHw](https://github.com/UhExooHw) For call screening flags
  
- [Polobard](https://github.com/polodarb/GMS-Flags-Reborn) for inspiration on the new flag system
    
- Pixelify Support Group Members for testing beta versions :)  
---

