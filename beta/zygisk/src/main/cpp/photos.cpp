#include <cstdlib>
#include <unistd.h>
#include <fcntl.h>
#include <string>
#include <android/log.h>

#include "zygisk.hpp"

#define PIXELIFY_TAG "PixelifyPhotos"
#include "module.h"

using zygisk::Api;
using zygisk::AppSpecializeArgs;

class PixelifyPhotos : public zygisk::ModuleBase {
public:
    void onLoad(Api *api, JNIEnv *env) override {
        this->api = api;
        this->env = env;
    }

    void preAppSpecialize(AppSpecializeArgs *args) override {
        if (!args || !args->nice_name) {
            api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
            return;
        }

        const char *raw = env->GetStringUTFChars(args->nice_name, nullptr);
        if (!raw) {
            api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
            return;
        }

        std::string process(raw);
        env->ReleaseStringUTFChars(args->nice_name, raw);

        if (process.find("com.google.android.apps.photos") == std::string::npos) {
            api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
            return;
        }

        if (access("/data/adb/modules/PixelifyNext/disable_photos", F_OK) == 0) {
            LOGI("Photos spoofing disabled by user");
            api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
            return;
        }

        should_spoof = true;
    }

    void postAppSpecialize(const AppSpecializeArgs *args) override {
        if (!should_spoof) return;
        injectMarlinProps();
    }

private:
    Api *api = nullptr;
    JNIEnv *env = nullptr;
    bool should_spoof = false;

    void setProp(jclass clazz, const char* field, const char* value) {
        jfieldID id = env->GetStaticFieldID(clazz, field, "Ljava/lang/String;");
        if (env->ExceptionCheck()) { env->ExceptionClear(); return; }
        if (id) {
            jstring jval = env->NewStringUTF(value);
            env->SetStaticObjectField(clazz, id, jval);
            env->DeleteLocalRef(jval);
        }
    }

    void injectSdkVersion(int sdk) {
        jclass ver = env->FindClass("android/os/Build$VERSION");
        if (!ver) { if (env->ExceptionCheck()) env->ExceptionClear(); return; }
        jfieldID id = env->GetStaticFieldID(ver, "DEVICE_INITIAL_SDK_INT", "I");
        if (env->ExceptionCheck()) { env->ExceptionClear(); return; }
        if (id) {
            env->SetStaticIntField(ver, id, (jint)sdk);
        }
    }

    void injectMarlinProps() {
        if (!env) return;

        jclass build = env->FindClass("android/os/Build");
        if (!build) {
            if (env->ExceptionCheck()) env->ExceptionClear();
            LOGW("Build class not found");
            return;
        }

        setProp(build, "BRAND", "google");
        setProp(build, "MANUFACTURER", "Google");
        setProp(build, "PRODUCT", "marlin");
        setProp(build, "DEVICE", "marlin");
        setProp(build, "MODEL", "Pixel XL");
        setProp(build, "FINGERPRINT", "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys");
        setProp(build, "TAGS", "release-keys");
        setProp(build, "TYPE", "user");

        injectSdkVersion(34);

        LOGI("Photos: Pixel XL spoof applied");
    }
};

REGISTER_ZYGISK_MODULE(PixelifyPhotos)
