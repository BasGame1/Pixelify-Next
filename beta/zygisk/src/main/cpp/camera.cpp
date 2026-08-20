#include <android/log.h>
#include <sys/system_properties.h>
#include <unistd.h>
#include <string>
#include <cstring>

#define PIXELIFY_TAG "PixelifyCameraFix"
#include "module.h"
#include "zygisk.hpp"

using zygisk::Api;
using zygisk::AppSpecializeArgs;

class CameraReverseSpoof : public zygisk::ModuleBase {
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

        bool is_camera = (process.find("GoogleCamera") != std::string::npos ||
                          process.find("com.android.camera") != std::string::npos ||
                          process.find("com.google.android.apps.cameralite") != std::string::npos);

        if (!is_camera) {
            api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
            return;
        }

        should_revert = true;
        LOGI("Camera detected: %s", process.c_str());
    }

    void postAppSpecialize(const AppSpecializeArgs *args) override {
        if (!should_revert) return;
        revertToOriginalProps();
    }

private:
    Api *api = nullptr;
    JNIEnv *env = nullptr;
    bool should_revert = false;

    std::string getSystemProp(const char* key) {
        char buffer[PROP_VALUE_MAX] = {0};
        if (__system_property_get(key, buffer) > 0) {
            return std::string(buffer);
        }
        return "";
    }

    void setProp(jclass clazz, const char* field, const char* value) {
        jfieldID id = env->GetStaticFieldID(clazz, field, "Ljava/lang/String;");
        if (env->ExceptionCheck()) { env->ExceptionClear(); return; }
        if (id && value && strlen(value) > 0) {
            jstring jval = env->NewStringUTF(value);
            env->SetStaticObjectField(clazz, id, jval);
            env->DeleteLocalRef(jval);
        }
    }

    void revertToOriginalProps() {
        if (!env) return;

        jclass build = env->FindClass("android/os/Build");
        if (!build) {
            if (env->ExceptionCheck()) env->ExceptionClear();
            LOGW("Build class not found");
            return;
        }

        std::string real_model = getSystemProp("ro.product.model");
        std::string real_product = getSystemProp("ro.product.name");
        std::string real_device = getSystemProp("ro.product.device");
        std::string real_manuf = getSystemProp("ro.product.manufacturer");
        std::string real_brand = getSystemProp("ro.product.brand");
        std::string real_fp = getSystemProp("ro.build.fingerprint");

        if (real_product.empty()) real_product = real_device;

        LOGI("Restoring: %s (%s)", real_model.c_str(), real_product.c_str());

        setProp(build, "MODEL", real_model.c_str());
        setProp(build, "PRODUCT", real_product.c_str());
        setProp(build, "DEVICE", real_device.c_str());
        setProp(build, "MANUFACTURER", real_manuf.c_str());
        setProp(build, "BRAND", real_brand.c_str());
        setProp(build, "FINGERPRINT", real_fp.c_str());
        setProp(build, "TAGS", "release-keys");
        setProp(build, "TYPE", "user");
    }
};

REGISTER_ZYGISK_MODULE(CameraReverseSpoof)
