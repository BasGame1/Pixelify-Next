#include <cstdlib>
#include <unistd.h>
#include <fcntl.h>
#include <string>
#include <vector>
#include <android/log.h>
#include <cstring>

#include "module.h"
#include "zygisk.hpp"

using zygisk::Api;
using zygisk::AppSpecializeArgs;

// Config Definitions
struct TargetDevice {
    const char* model;
    const char* product;
    const char* fingerprint;
};

const TargetDevice DEV_P1 = {"Pixel XL", "marlin", "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys"};
const TargetDevice DEV_P5 = {"Pixel 5", "redfin", "google/redfin/redfin:13/TQ2A.230305.008.C1/9619669:user/release-keys"};

class pixelify_photos : public zygisk::ModuleBase {
public:
    void onLoad(Api *api, JNIEnv *env) override {
        this->api = api;
        this->env = env;
    }

    void preAppSpecialize(AppSpecializeArgs *args) override {
        if (!args || !args->nice_name) return;

        const char *process = env->GetStringUTFChars(args->nice_name, nullptr);
        if (process) {
            std::string package(process);
            target_config = getSpoofConfig(package);
            
            if (target_config) {
                 LOGI("Target detected: %s -> Spoofing %s", process, target_config->model);
            }

            env->ReleaseStringUTFChars(args->nice_name, process);
        }
    }

    void postAppSpecialize(const AppSpecializeArgs *) override {
        if (target_config) {
            injectBuild(*target_config);
            
            // Version spoofing specific to P1
            // Check if model is Pixel XL (P1)
            if (strcmp(target_config->model, "Pixel XL") == 0) {
                 injectVersion(34);
            } 
            // Older logic injected 27 (8.1.0) for some, update here if needed.
        }
    }

private:
    Api *api;
    JNIEnv *env;
    const TargetDevice* target_config = nullptr;

    const TargetDevice* getSpoofConfig(const std::string& package) {
        // Exclusions
        static const std::vector<std::string> keep = {
            "com.google.android.gms.chimera", 
            "com.google.android.gms.update",
            "com.google.android.gms.unstable"
        };
        for (const auto& s : keep) {
            if (package.find(s) != std::string::npos) return nullptr;
        }

        // P1 List
        if (package.find("com.google.android.apps.photos") != std::string::npos) {
            return &DEV_P1;
        }

        // P5 List
        if (package.find("com.google.android.gms") != std::string::npos) {
            return &DEV_P5;
        }

        return nullptr;
    }

    void injectBuild(const TargetDevice& dev) {
        if (!env) return;
        jclass build_class = env->FindClass("android/os/Build");
        if (!build_class) { if(env->ExceptionCheck()) env->ExceptionClear(); return; }

        setStaticString(build_class, "BRAND", "google");
        setStaticString(build_class, "MANUFACTURER", "Google");
        setStaticString(build_class, "PRODUCT", dev.product);
        setStaticString(build_class, "DEVICE", dev.product);
        setStaticString(build_class, "MODEL", dev.model);
        setStaticString(build_class, "TAGS", "release-keys");
        setStaticString(build_class, "TYPE", "user");
        setStaticString(build_class, "FINGERPRINT", dev.fingerprint);
    }

    void injectVersion(int sdkVer) {
        jclass version_class = env->FindClass("android/os/Build$VERSION");
        if (!version_class) { if(env->ExceptionCheck()) env->ExceptionClear(); return; }

        jfieldID sdk_id = env->GetStaticFieldID(version_class, "DEVICE_INITIAL_SDK_INT", "I");
        if (env->ExceptionCheck()) env->ExceptionClear(); // Clear if field doesn't exist
        
        if (sdk_id != nullptr) {
            env->SetStaticIntField(version_class, sdk_id, (jint)sdkVer);
        }
    }

    void setStaticString(jclass clazz, const char* fieldName, const char* value) {
        jfieldID fieldId = env->GetStaticFieldID(clazz, fieldName, "Ljava/lang/String;");
        if (env->ExceptionCheck()) { env->ExceptionClear(); return; }
        if (fieldId) {
            jstring jValue = env->NewStringUTF(value);
            env->SetStaticObjectField(clazz, fieldId, jValue);
            env->DeleteLocalRef(jValue);
        }
    }
};

REGISTER_ZYGISK_MODULE(pixelify_photos)
