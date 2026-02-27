#include <cstdlib>
#include <unistd.h>
#include <fcntl.h>
#include <string>
#include <vector>
#include <android/log.h>
#include <sys/system_properties.h>

#include "module.h"
#include "zygisk.hpp"

using zygisk::Api;
using zygisk::AppSpecializeArgs;

class PixelifyPhotos : public zygisk::ModuleBase {
public:
    void onLoad(Api *api, JNIEnv *env) override {
        this->api = api;
        this->env = env;
    }

    void preAppSpecialize(AppSpecializeArgs *args) override {
        if (!args || !args->nice_name) return;

        const char *raw_process = env->GetStringUTFChars(args->nice_name, nullptr);
        if (!raw_process) return;

        std::string process(raw_process);
        env->ReleaseStringUTFChars(args->nice_name, raw_process);

        // 1. TARGET CHECK: Only run for Google Photos
        if (process.find("com.google.android.apps.photos") == std::string::npos) {
            return;
        }

        // 2. WEBUI CHECK: Stop if user disabled it
        if (access("/data/adb/modules/pixelify-next/disable_photos", F_OK) == 0) {
            LOGI("Unlimited Storage disabled via WebUI");
            return;
        }

        LOGI("Google Photos detected! Applying Pixel XL (Marlin) spoof for Unlimited Storage...");
        injectMarlinProps();
    }

private:
    Api *api;
    JNIEnv *env;

    void injectMarlinProps() {
        if (!env) return;

        jclass build_class = env->FindClass("android/os/Build");
        if (!build_class) {
            if (env->ExceptionCheck()) env->ExceptionClear();
            LOGW("Could not find android.os.Build class");
            return;
        }

        // THE "MARLIN" CONFIGURATION
        // This specific combination is required for Unlimited Original Quality
        setProp(build_class, "BRAND", "google");
        setProp(build_class, "MANUFACTURER", "Google");
        setProp(build_class, "PRODUCT", "marlin");
        setProp(build_class, "DEVICE", "marlin");
        setProp(build_class, "MODEL", "Pixel XL");
        setProp(build_class, "FINGERPRINT", "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys");
        setProp(build_class, "TAGS", "release-keys");
        setProp(build_class, "TYPE", "user");

        // Spoof Version to Android 14 (SDK 34) to prevent "Update Required" nags
        injectSdkVersion(34);
    }

    void setProp(jclass clazz, const char* field, const char* value) {
        jfieldID id = env->GetStaticFieldID(clazz, field, "Ljava/lang/String;");
        if (env->ExceptionCheck()) { env->ExceptionClear(); return; }
        
        if (id != nullptr) {
            jstring jVal = env->NewStringUTF(value);
            env->SetStaticObjectField(clazz, id, jVal);
            env->DeleteLocalRef(jVal);
        }
    }

    void injectSdkVersion(int sdkVer) {
        jclass version_class = env->FindClass("android/os/Build$VERSION");
        if (!version_class) { if(env->ExceptionCheck()) env->ExceptionClear(); return; }

        jfieldID sdk_id = env->GetStaticFieldID(version_class, "DEVICE_INITIAL_SDK_INT", "I");
        if (env->ExceptionCheck()) env->ExceptionClear();
        
        if (sdk_id) {
            env->SetStaticIntField(version_class, sdk_id, (jint)sdkVer);
        }
    }
};

REGISTER_ZYGISK_MODULE(PixelifyPhotos)
