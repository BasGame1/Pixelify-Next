#include <cstdlib>
#include <unistd.h>
#include <string>
#include <fcntl.h>
#include <android/log.h>
#include <cstring>

#include "zygisk.hpp"
#include "module.h"

using zygisk::Api;
using zygisk::AppSpecializeArgs;
using zygisk::ServerSpecializeArgs;

class PixelifyTensor : public zygisk::ModuleBase {
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

        std::string pkg(process);
        env->ReleaseStringUTFChars(args->nice_name, process);

        if (pkg.find("com.google.android.apps.photos") != std::string::npos) {
            should_spoof = true;
        } else {
            api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
        }
    }

    void postAppSpecialize(const AppSpecializeArgs *args) override {
        if (!should_spoof) return;
        injectBuild("Pixel XL", "marlin",
                    "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys");
    }

private:
    Api *api = nullptr;
    JNIEnv *env = nullptr;
    bool should_spoof = false;

    void setStaticString(jclass clazz, const char* field, const char* value) {
        jfieldID id = env->GetStaticFieldID(clazz, field, "Ljava/lang/String;");
        if (env->ExceptionCheck()) { env->ExceptionClear(); return; }
        if (id) {
            jstring jval = env->NewStringUTF(value);
            env->SetStaticObjectField(clazz, id, jval);
            env->DeleteLocalRef(jval);
        }
    }

    void injectBuild(const char *model, const char *product, const char *fp) {
        if (!env) return;

        jclass build = env->FindClass("android/os/Build");
        if (!build) {
            if (env->ExceptionCheck()) env->ExceptionClear();
            return;
        }

        setStaticString(build, "BRAND", "google");
        setStaticString(build, "MANUFACTURER", "Google");
        setStaticString(build, "PRODUCT", product);
        setStaticString(build, "DEVICE", product);
        setStaticString(build, "MODEL", model);
        setStaticString(build, "FINGERPRINT", fp);
    }
};

REGISTER_ZYGISK_MODULE(PixelifyTensor)
