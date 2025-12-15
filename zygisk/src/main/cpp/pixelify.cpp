#include <cstdlib>
#include <unistd.h>
#include <fcntl.h>
#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include <android/log.h>
#include <cstring>

#include "module.h"
#include "zygisk.hpp"

using zygisk::Api;
using zygisk::AppSpecializeArgs;
using zygisk::ServerSpecializeArgs;

using namespace pixelifytag;

// Debug flag
static bool DEBUG = true;

// Configuration Struct for Device Props
struct DeviceConfig {
    std::string model;
    std::string product;
    std::string fingerprint;
    int sdk_version; // -1 if not needed
    std::string hardware; // empty if not needed
};

// Device Definitions
const DeviceConfig PIXEL_XL = {
    "Pixel XL", "marlin", "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys", 34, ""
};
const DeviceConfig PIXEL_2 = {
    "Pixel 2", "walleye", "google/walleye/walleye:8.1.0/OPM1.171019.011/4448085:user/release-keys", 27, ""
};
const DeviceConfig PIXEL_5 = {
    "Pixel 5", "redfin", "google/redfin/redfin:13/TQ2A.230305.008.C1/9619669:user/release-keys", -1, ""
};
const DeviceConfig PIXEL_6_PRO = {
    "Pixel 6 Pro", "raven", "google/raven/raven:13/TQ1A.230105.002/9325679:user/release-keys", -1, ""
};
const DeviceConfig PIXEL_7_PRO = {
    "Pixel 7 Pro", "cheetah", "google/cheetah/cheetah:13/TQ2A.230305.008.C1/9619669:user/release-keys", -1, ""
};
const DeviceConfig PIXEL_FOLD = {
    "Pixel Fold", "felix", "google/felix/felix:13/TD3A.230203.070.A1/10075871:user/release-keys", -1, "felix"
};
const DeviceConfig PIXEL_8_PRO = {
    "Pixel 8 Pro", "husky", "google/husky/husky:14/UD1A.230803.041/10808477:user/release-keys", -1, ""
};
const DeviceConfig PIXEL_9_PRO = {
    // This firngerprint its wrong, but i couldnt find one
    "Pixel 9 Pro", "caiman", "google/caiman_beta/caiman:16/BP41.250916.015.A1/10808477:user/release-keys", -1, ""
};
const DeviceConfig PIXEL_10_PRO = {
    "Pixel 9 Pro", "Blazer", "google/blazer_beta/blazer:16/BP41.250916.015.A1/14331773:user/release-keys", -1, ""
};

class pixelify : public zygisk::ModuleBase {
public:
    void onLoad(Api *api, JNIEnv *env) override {
        this->api = api;
        this->env = env;
    }

    void preAppSpecialize(AppSpecializeArgs *args) override {
        // Retrieve process name using JNI
        if (!args || !args->nice_name) return;
        
        const char *process = env->GetStringUTFChars(args->nice_name, nullptr);
        if (process) {
            std::string package_name(process);
            spoof_device = getSpoofConfig(package_name);
            should_spoof = (spoof_device != nullptr);
            
            if (should_spoof && DEBUG) {
                LOGI("Detected target app: %s, preparing to spoof as %s", process, spoof_device->model.c_str());
            }
            
            env->ReleaseStringUTFChars(args->nice_name, process);
        }
    }

    void postAppSpecialize(const AppSpecializeArgs *) override {
        if (should_spoof && spoof_device) {
            injectProps(*spoof_device);
        }
    }

private:
    Api *api;
    JNIEnv *env;
    const DeviceConfig* spoof_device = nullptr;
    bool should_spoof = false;

    // Helper to determine which device to spoof based on package name
    const DeviceConfig* getSpoofConfig(const std::string& package) {
        static const std::vector<std::string> keep_list = {
            "com.google.android.apps.recorder",
            "com.google.android.GoogleCamera",
            "com.google.android.apps.motionsense.bridge",
            "com.google.android.gms.chimera",
            "com.google.android.gms.update",
            "com.android.camera",
            "com.google.android.xx",
            "com.google.android.googlequicksearchbox:HotwordDetectionService",
            "com.google.android.apps.mesagging:rcs", 
            "com.google.android.googlequicksearchbox:trusted:com.google.android.apps.gsa.hotword.hotworddetectionservice.GsaHotwordDetectionService"
        };

        for (const auto& s : keep_list) {
             if (package.find(s) != std::string::npos) return nullptr;
        }

        // 2. Special Case: Unstable GMS -> Pixel 2
        if (package == "com.google.android.gms.unstable") {
            return &PIXEL_2;
        }

        // 3. Mapping packages to devices
        // Using a map for efficient lookup logic
        static const std::vector<std::pair<std::vector<std::string>, const DeviceConfig*>> spoof_map = {
            {{"com.google.android.apps.photos"}, &PIXEL_XL}, // P1
            {{
                "com.google.android.gms",
                "com.google.ar.core",
                "com.google.vr.apps.ornament",
                "com.google.android.tts",
                "com.google.android.apps.wearables.maestro.companion",
                "com.nothing.smartcenter",
                "com.netflix.mediaclient"
            }, &PIXEL_5}, // P5
            {{"com.google"}, &PIXEL_6_PRO}, // P6
            {{}, &PIXEL_7_PRO}, // P7 (Empty in original code, kept for structure)
            {{
                "com.google.pixel.livewallpaper",
                "com.google.android.apps.subscriptions.red",
                "com.breel.wallpaper",
                "com.snapchat.android",
                "com.google.process.gapps",
                "com.google.process.gservices",
                "com.google.android.googlequicksearchbox",
                "com.adobe.lrmobile"
            }, &PIXEL_8_PRO}, // P8
             {{"com.google.android.apps.subscriptions.red"}, &PIXEL_FOLD} // Fold
        };

        // Iterate through the map to find a match
        // Note: We check P8 list first or last? The original code checked P8 before P5/P6/P7.
        // The order here preserves your original logic: P1 -> P8 -> P5 -> P7 -> Fold -> P6
        
        // P1
        for (const auto& s : {"com.google.android.apps.photos"}) 
            if (package.find(s) != std::string::npos) return &PIXEL_XL;

        // P8
        for (const auto& s : {
            "com.google.pixel.livewallpaper", "com.google.android.apps.subscriptions.red", 
            "com.breel.wallpaper", "com.snapchat.android", "com.google.android.gms", 
            "com.google.process.gapps", "com.google.process.gservices",
            "com.google.android.googlequicksearchbox","com.adobe.lrmobile"
        }) if (package.find(s) != std::string::npos) return &PIXEL_8_PRO;

        // P5
        for (const auto& s : {
             "com.google.android.gms","com.google.ar.core", "com.google.vr.apps.ornament",
             "com.google.android.tts", "com.google.android.apps.wearables.maestro.companion", 
             "com.nothing.smartcenter","com.netflix.mediaclient"
        }) if (package.find(s) != std::string::npos) return &PIXEL_5;

        // P7 
        // (List was empty in original, skipping)

        // Fold
        for (const auto& s : {"com.google.android.apps.subscriptions.red"})
            if (package.find(s) != std::string::npos) return &PIXEL_FOLD;

        // P6
        for (const auto& s : {"com.google"})
            if (package.find(s) != std::string::npos) return &PIXEL_6_PRO;

        return nullptr;
    }

    void injectProps(const DeviceConfig& device) {
        if (env == nullptr) {
            LOGW("Env is null, cannot inject");
            return;
        }

        jclass build_class = env->FindClass("android/os/Build");
        if (build_class == nullptr) {
            LOGW("Build class not found");
            return;
        }

        if (DEBUG) {
            LOGI("Injecting Props: Model=%s, Product=%s", device.model.c_str(), device.product.c_str());
        }

        // Common Fields
        setStaticString(build_class, "BRAND", "google");
        setStaticString(build_class, "MANUFACTURER", "Google");
        setStaticString(build_class, "PRODUCT", device.product.c_str());
        setStaticString(build_class, "DEVICE", device.product.c_str());
        setStaticString(build_class, "MODEL", device.model.c_str());
        setStaticString(build_class, "TAGS", "release-keys");
        setStaticString(build_class, "TYPE", "user");
        setStaticString(build_class, "FINGERPRINT", device.fingerprint.c_str());

        // Optional Hardware Injection
        if (!device.hardware.empty()) {
             setStaticString(build_class, "HARDWARE", device.hardware.c_str());
        }

        // Optional Version/SDK Injection
        if (device.sdk_version != -1) {
            injectSdkVersion(device.sdk_version);
        }
    }

    void setStaticString(jclass clazz, const char* fieldName, const char* value) {
        jfieldID fieldId = env->GetStaticFieldID(clazz, fieldName, "Ljava/lang/String;");
        if (env->ExceptionCheck()) { env->ExceptionClear(); return; }
        
        if (fieldId != nullptr) {
            jstring jValue = env->NewStringUTF(value);
            env->SetStaticObjectField(clazz, fieldId, jValue);
            env->DeleteLocalRef(jValue);
        }
    }

    void injectSdkVersion(int sdkVer) {
        jclass version_class = env->FindClass("android/os/Build$VERSION");
        if (env->ExceptionCheck() || version_class == nullptr) {
            env->ExceptionClear();
            return;
        }

        // DEVICE_INITIAL_SDK_INT was added in API 31. On older devices, this ID will be null.
        jfieldID sdk_id = env->GetStaticFieldID(version_class, "DEVICE_INITIAL_SDK_INT", "I");
        if (env->ExceptionCheck()) { env->ExceptionClear(); }

        if (sdk_id != nullptr) {
            env->SetStaticIntField(version_class, sdk_id, (jint)sdkVer);
        }
    }
};

REGISTER_ZYGISK_MODULE(pixelify)
