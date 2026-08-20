### Installation instructions for latest version
- Make Sure Play Store not installing when Pixelify is installing.
- If using KSU, install KSU zygisk module first
- Add Google Play Services and inside com.google.android.gms.unstable in DenyList.
- On installation, If see error when installing Google Photos, then uninstalling updates of google apps
---
### Installation instructions for Pixel Launcher
- Your launcher app *WILL* crash, so go to settings
- Search for deafult apps
- And select Pixel Launcher as your default home launcher
---
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
- Pixel 10 Pro:- AICore and AI apps
- Pixel 9 Pro XL:- Dialer functions
- Pixel 8 Pro / Pixel 6 Pro:- Rest Google apps except (all Google camera package)
<br><br>**Note** :- Zygisk spoofing can be configured per-app directly from the WebUI.
