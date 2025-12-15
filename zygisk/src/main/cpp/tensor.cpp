#include <cstdlib>
#include <unistd.h>
#include <string>
#include <vector>
#include <fcntl.h>
#include <android/log.h>
#include <cstring>

#include "zygisk.hpp"
#include "module.h"

using zygisk::Api;
using zygisk::AppSpecializeArgs;
using zygisk::ServerSpecializeArgs;


class pixelify : public zygisk::ModuleBase {
public:
    void onLoad(Api *api, JNIEnv *env) override {
        this->api = api;
        this->env = env;
    }

    void preAppSpecialize(AppSpecializeArgs *args) override {
        if (!args || !args->nice_name) return;

        const char *process = env->GetStringUTFChars(args->nice_name, nullptr);
        if (process) {
            preSpecialize(process);
            env->ReleaseStringUTFChars(args->nice_name, process);
        }
    }

    void preServerSpecialize(ServerSpecializeArgs *args) override {
        preSpecialize("system_server");
    }

private:
    Api *api;
    JNIEnv *env;

    void injectBuild(const std::string& package_name, const char *model1, const char *product1, const char *finger1) {
        if (env == nullptr) return;

        jclass build_class = env->FindClass("android/os/Build");
        if (build_class == nullptr) {
            if (env->ExceptionCheck()) env->ExceptionClear();
            LOGW("Failed to inject Build for %s: class not found", package_name.c_str());
            return;
        }

        LOGI("Injecting for %s: Product=%s, Model=%s", package_name.c_str(), product1, model1);

        setStaticString(build_class, "BRAND", "google");
        setStaticString(build_class, "MANUFACTURER", "Google");
        setStaticString(build_class, "PRODUCT", product1);
        setStaticString(build_class, "DEVICE", product1);
        setStaticString(build_class, "MODEL", model1);
        
        if (finger1 != nullptr && strlen(finger1) > 0) {
            setStaticString(build_class, "FINGERPRINT", finger1);
        }
    }

    // Helper to set fields safely
    void setStaticString(jclass clazz, const char* fieldName, const char* value) {
        jfieldID fieldId = env->GetStaticFieldID(clazz, fieldName, "Ljava/lang/String;");
        if (env->ExceptionCheck()) { env->ExceptionClear(); return; }
        
        if (fieldId != nullptr) {
            jstring jValue = env->NewStringUTF(value);
            env->SetStaticObjectField(clazz, fieldId, jValue);
            env->DeleteLocalRef(jValue);
        }
    }

    void preSpecialize(const char *process) {
        if (!process) return;

        // Handle Companion Request safely
        unsigned r = 0;
        int fd = api->connectCompanion();
        if (fd >= 0) {
            read(fd, &r, sizeof(r));
            close(fd);
        }

        std::string package_name(process);

        // Logic for Google Photos -> Pixel XL
        if (package_name.find("com.google.android.apps.photos") != std::string::npos) {
            injectBuild(package_name, "Pixel XL", "marlin", "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys");
        }

        api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
    }
};

static int urandom = -1;

static void companion_handler(int i) {
    if (urandom < 0) {
        urandom = open("/dev/urandom", O_RDONLY);
    }
    if (urandom >= 0) {
        unsigned r;
        read(urandom, &r, sizeof(r));
        // LOGD("Companion r=[%u]", r); 
        write(i, &r, sizeof(r));
    } else {
        // Fallback if urandom fails
        unsigned r = 0;
        write(i, &r, sizeof(r));
    }
}

REGISTER_ZYGISK_MODULE(pixelify)
REGISTER_ZYGISK_COMPANION(companion_handler)
