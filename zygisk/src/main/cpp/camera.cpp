#include <android/log.h>
#include <sys/system_properties.h>
#include <unistd.h>
#include <string>
#include <vector>
#include <cstring>

#include "zygisk.hpp"
#include "module.h"

#define LOG_TAG "PixelifyCamera"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__)

using zygisk::Api;
using zygisk::AppSpecializeArgs;

class CameraReverseSpoof : public zygisk::ModuleBase {
public:
    void onLoad(Api *api, JNIEnv *env) override {
        this->api = api;
        this->env = env;
    }

    void preAppSpecialize(AppSpecializeArgs *args) override {
        if (!args || !args->nice_name) return;

        const char *raw_process = env->GetStringUTFChars(args->nice_name, nullptr);
        std::string process_name;
        if (raw_process) {
            process_name = raw_process;
            env->ReleaseStringUTFChars(args->nice_name, raw_process);
        } else {
            return;
        }

        // Identify Camera Apps
        if (process_name.find("GoogleCamera") != std::string::npos || 
            process_name.find("com.android.camera") != std::string::npos ||
            process_name.find("com.google.android.apps.cameralite") != std::string::npos) {
            
            LOGI("Detected Camera App: %s. Action: REVERSE SPOOF (Restoring Original Props)", process_name.c_str());
            revertToOriginalProps();
        }
    }

private:
    Api *api;
    JNIEnv *env;

    // Helper function to read the REAL system properties (ignoring standard Magisk/Zygisk spoofs)
    std::string getSystemProp(const char* key) {
        char buffer[PROP_VALUE_MAX] = {0};
        // __system_property_get reads the low-level properties directly.
        // Unless something hooked this C function specifically, it returns the true values.
        __system_property_get(key, buffer);
        return std::string(buffer);
    }

    void revertToOriginalProps() {
        if (!env) return;

        jclass build_class = env->FindClass("android/os/Build");
        if (!build_class) {
            if (env->ExceptionCheck()) env->ExceptionClear();
            return;
        }

        // 1. Fetch the TRUE properties from the device itself
        std::string real_model = getSystemProp("ro.product.model");
        std::string real_product = getSystemProp("ro.product.name"); 
        std::string real_device = getSystemProp("ro.product.device");
        std::string real_manuf = getSystemProp("ro.product.manufacturer");
        std::string real_brand = getSystemProp("ro.product.brand");
        std::string real_fingerprint = getSystemProp("ro.build.fingerprint");

        // Fallback: If ro.product.name is empty, use ro.product.device
        if (real_product.empty()) real_product = real_device;

        LOGI("Restoring original model: %s (%s)", real_model.c_str(), real_product.c_str());

        // 2. Inject these REAL values back into the Java Build class
        // This overwrites whatever main.cpp might have done.
        setProp(build_class, "MODEL", real_model.c_str());
        setProp(build_class, "PRODUCT", real_product.c_str());
        setProp(build_class, "DEVICE", real_device.c_str());
        setProp(build_class, "MANUFACTURER", real_manuf.c_str());
        setProp(build_class, "BRAND", real_brand.c_str());
        setProp(build_class, "FINGERPRINT", real_fingerprint.c_str());
        
        // Ensure "TAGS" and "TYPE" are also consistent if needed, 
        // though usually MODEL/PRODUCT are the crash causes.
    }

    void setProp(jclass clazz, const char* field, const char* value) {
        jfieldID id = env->GetStaticFieldID(clazz, field, "Ljava/lang/String;");
        // Always clear exceptions immediately to prevent crashes
        if (env->ExceptionCheck()) { env->ExceptionClear(); return; }
        
        if (id != nullptr && value != nullptr) {
            jstring jVal = env->NewStringUTF(value);
            env->SetStaticObjectField(clazz, id, jVal);
            env->DeleteLocalRef(jVal);
        }
    }
};

REGISTER_ZYGISK_MODULE(CameraReverseSpoof)
