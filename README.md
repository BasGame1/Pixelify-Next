# PIXELIFY NEXT MAGISK MODULE
![Platform](https://img.shields.io/badge/Platform-Android-green?style=flat-square&logo=android)
![Static Badge](https://img.shields.io/badge/Language-Bash-blue?logo=GNU%20Bash)
<p>
A Magisk Module which enables Pixel UI and some exclusive features.<br>
# WORK IN PROGRESS

## 🐛 Bugs
- **Pixel Launcher on android 16 qpr1 and qpr2**
- **Flag system (ex. dialer features or editor features) due to server side changed**
## ⭐ Requirements
- **Supported Android Versions: Android 7.0 to Android 16**
- **ARM64 or ARM32 device**
- **Volume Keys (optional)**
- **Internet for downloading NGA Resources, Pixel Livewallpaper, Device Personalization Services & Pixel Launcher**
- **Magisk v24 or above from Pixelify v2+**
- **Zygisk (Recommended but not mandatory, needed for spoofing functions)**
- **NOTE: Flash the module zip file in the Magisk Manager app only; flashing the module in TWRP or any other recovery won't work.**

## 📞 Contact (for errors or suggestions)
- Telegram (https://t.me/basgame1)
- Group Chat (https://t.me/PixelifyNext)
- Group Channel (https:/t.me/Pixelifychannel)
- Xda (https://xdaforums.com/m/basgame1.13021465/)
- Github Issues (https://github.com/BasGame1/Pixelify-Next/issues)
### ❌ Unsupported Roms
- Realme Ui (Android 14), Oxygen Os (Android 14), axion Os (Android 16) will not work. It will bootloop rom after reboot. only way is to fix it by factory reset. 
#Don't Flash Pixelify Next on it

### 📱 Supported Roms
- Tested on LineageOS (Android 15 and 16)

### Installation instructions for v4
- Make Sure Play Store not installing when Pixelify is installing.
- If using KSU, install KSU zygisk module first
- Add Google Play Services and inside com.google.android.gms.unstable in DenyList.
- On installation, If see error when installing Google Photos, then uninstalling updates of google apps

### Installation instructions for Pixel Launcher
- Your launcher app will crash, so go to settings
- Search for deafult apps
- And select Pixel Launcher as your default home launcher

### After Installations (For First Time Pixelify Next Installation):-
1) Playstore
- Clear Playstore data
- Open Playstore for 5-10 secs
- Force Stop Playstore
- Update Google App (For NGA & NGA Voice Typing)
- Untick Auto Updates for Google Photos, Android System Intelligence (Don't Update these app from playstore)

2)  Google Dialer
- Clear Data
- Open it for 5-10 secs
- Force Stop Google Dialer
- Open Google Dialer

3) Google App
- After Updating Google app from playstore
- Launch Google Assistant
- Let it Download and setup everything
- After setting up, automatically NGA Voice should work.

4) If NGA Voice typing not working then
- Set main Language of phone and Gboard to Supported NGA Languages
- Download 50xx Voice Pack in Google app
- Restart

5) Google Photos
- Clear Data
- Make sure connected to WiFi
- You may receive Updating Photos Editor, wait for it.
- Google Photos may download around 300-400mb only with WiFi

*Note:* Photos editor tool struck  Editing Tool will install soon 
- First Wait for sometimes and connect with WiFi
- Reboot
- if still not fixed (Reinstall Pixelify;- sometimes flags doesn't get patched due to gms performing action on database)

Working of Magic Editor, New Automatic Call Screening depends on Device, Kernel.

If Some features not working,
- Make Sure to Select YES for Disable Internal Spoofing
- Check file /sdcard/Pixelify/flaglog.txt
if you find Status: Error xxxxx on some flags, then you may need to reinstall pixelify.

### Installation without Volume Keys
- Use packages with Pixelify-${version}-no_VK.zip
- Place config.prop in your internal storage>Pixelify (/sdcard/Pixelify/config.prop)
- Edit the prop file according to what features you want
- (If you have any problem placing config.prop there then you also can extract and update config.prop inside the packages it automatically use it.) 

### Zygisk spoofing configuration
- Pixel XL:- Google Photos
- Pixel 9 Pro XL:- Dialer functions
- Pixel 6 Pro:- Rest Google apps except (all Google camera package)
<br><br>**Note** :- Zygisk spoofing can't override PixelProp Utils.

### Features of Pixelify module
- Initial Size of module is low
- Open Source
- Works with most of Android version
- Uses Dynamic spoofing (Zygisk) for only Google apps to prevent crashes and other issues
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
- Patches Flags to force enable pixel features

## ⭐ Pixel Features
(They may not work depending on the device, bc some are server side, but report them if they dont work, u are adviced)
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

## Contribute to project
- Reporting bugs with logs
- Feature Requests
- Supporting other persons on issues or telegram (t.me/@basgame1)
- Creating pull request to enable new feature or code improvements

## Other projects
- Circle to search (github link)(Lsposed neccesary) <a href=https://github.com/parallelcc/MiCTS/tree/v2.3>MyCTS by parallelcc<a>
- Call recording (github link)<a href=https://github.com/chenxiaolong/BCR>Call recording by chenxiaolong<a>
- Pixel studio enabler (TG link) (if pixel studio crashes) <a href=https://t.me/GappsLeaks/933>Pixel Studio Enabler by GappsLeaks (TG)<a>

## ⭐ Credits
- Google for creating these awesome features
- [Tristan] (https://t.me/@Tristan_xxxxx) For sending the Pixel Launcher files and Journal app
- [topjohnwu](https://github.com/topjohnwu) for Magisk
- [#TeamFiles](https://t.me/modulesrepo) for so many themed icons for Pixel Launcher android 12
- [Kdrag0n](https://github.com/kdrag0n) for SimpleDeviceConfig
- [Freak07](https://forum.xda-developers.com/m/freak07.3428502/) for Adaptive Sound
- [Pranav Pandey](https://forum.xda-developers.com/m/pranav-pandey.3962236/) for BreelWallpaper2020 Port
- [HuskyDG](https://github.com/HuskyDG) for intial Riru Port, Bootloop saver
- [Enzo Ariel] (https://github.com/enzosanchezariel) for pixel launcher fix 
- [Saitama](https://github.com/saitamasahil) Fixing Pixel Launcher crashes
- [Gapps Flag Leaks](https://t.me/GappsLeaks) AssembleDebug For some flags
- [Mewona] (https://t.me/@TempMeow) For Pixel Launcher files
- [Kevin] for gemini bootanimation
- [SQlite Organization] (https://www.sqlite.org/) for SQlite3 uncompiled files
- Pixelify Support Group Members for testing beta versions :)
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










