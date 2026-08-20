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

struct TargetDevice {
    const char* model;
    const char* product;
    const char* fingerprint;
};

static const TargetDevice DEV_P1 = {
    "Pixel XL", "marlin",
    "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys"
};

static const TargetDevice DEV_P5 = {
    "Pixel 5", "redfin",
    "google/redfin/redfin:14/AP2A.240805.005/12025142:user/release-keys"
};

class PixelifyTensor2 : public zygisk::ModuleBase {
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

        const char *process = env->GetStringUTFChars(args->nice_name, nullptr);
        if (!process) {
            api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
            return;
        }

        std::string package(process);
        env->ReleaseStringUTFChars(args->nice_name, process);

        target_config = getSpoofConfig(package);

        if (!target_config) {
            api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
            return;
        }

        LOGI("Target: %s -> %s", package.c_str(), target_config->model);
    }

    void postAppSpecialize(const AppSpecializeArgs *args) override {
        if (!target_config) return;

        injectBuild(*target_config);

        if (strcmp(target_config->model, "Pixel XL") == 0) {
            injectVersion(34);
        }
    }

private:
    Api *api = nullptr;
    JNIEnv *env = nullptr;
    const TargetDevice* target_config = nullptr;

    const TargetDevice* getSpoofConfig(const std::string& package) {
        if (package.find("com.google.android.gms.chimera") != std::string::npos ||
            package.find("com.google.android.gms.update") != std::string::npos ||
            package == "com.google.android.gms.unstable") {
            return nullptr;
        }

        if (package.find("com.google.android.apps.photos") != std::string::npos) {
            return &DEV_P1;
        }

        if (package.find("com.google.android.gms") != std::string::npos) {
            return &DEV_P5;
        }

        return nullptr;
    }

    void setStaticString(jclass clazz, const char* field, const char* value) {
        jfieldID id = env->GetStaticFieldID(clazz, field, "Ljava/lang/String;");
        if (env->ExceptionCheck()) { env->ExceptionClear(); return; }
        if (id) {
            jstring jval = env->NewStringUTF(value);
            env->SetStaticObjectField(clazz, id, jval);
            env->DeleteLocalRef(jval);
        }
    }

    void injectBuild(const TargetDevice& dev) {
        if (!env) return;
        jclass build = env->FindClass("android/os/Build");
        if (!build) { if (env->ExceptionCheck()) env->ExceptionClear(); return; }

        setStaticString(build, "BRAND", "google");
        setStaticString(build, "MANUFACTURER", "Google");
        setStaticString(build, "PRODUCT", dev.product);
        setStaticString(build, "DEVICE", dev.product);
        setStaticString(build, "MODEL", dev.model);
        setStaticString(build, "TAGS", "release-keys");
        setStaticString(build, "TYPE", "user");
        setStaticString(build, "FINGERPRINT", dev.fingerprint);
    }

    void injectVersion(int sdk) {
        jclass ver = env->FindClass("android/os/Build$VERSION");
        if (!ver) { if (env->ExceptionCheck()) env->ExceptionClear(); return; }
        jfieldID id = env->GetStaticFieldID(ver, "DEVICE_INITIAL_SDK_INT", "I");
        if (env->ExceptionCheck()) { env->ExceptionClear(); return; }
        if (id) {
            env->SetStaticIntField(ver, id, (jint)sdk);
        }
    }
};

REGISTER_ZYGISK_MODULE(PixelifyTensor2)
