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
using zygisk::ServerSpecializeArgs;

static bool DEBUG = false;

struct DeviceConfig {
    const char* model;
    const char* product;
    const char* fingerprint;
    int sdk_version;
    const char* hardware;
};

static const DeviceConfig PIXEL_XL = {
    "Pixel XL", "marlin",
    "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys",
    34, nullptr
};

static const DeviceConfig PIXEL_2 = {
    "Pixel 2", "walleye",
    "google/walleye/walleye:8.1.0/OPM1.171019.011/4448085:user/release-keys",
    27, nullptr
};

static const DeviceConfig PIXEL_5 = {
    "Pixel 5", "redfin",
    "google/redfin/redfin:14/AP2A.240805.005/12025142:user/release-keys",
    -1, nullptr
};

static const DeviceConfig PIXEL_6_PRO = {
    "Pixel 6 Pro", "raven",
    "google/raven/raven:14/AP2A.240805.005/12025142:user/release-keys",
    -1, nullptr
};

static const DeviceConfig PIXEL_7_PRO = {
    "Pixel 7 Pro", "cheetah",
    "google/cheetah/cheetah:14/AP2A.240805.005/12025142:user/release-keys",
    -1, nullptr
};

static const DeviceConfig PIXEL_FOLD = {
    "Pixel Fold", "felix",
    "google/felix/felix:14/AP2A.240805.005/12025142:user/release-keys",
    -1, "felix"
};

static const DeviceConfig PIXEL_8_PRO = {
    "Pixel 8 Pro", "husky",
    "google/husky/husky:14/AP2A.240805.005/12025142:user/release-keys",
    -1, nullptr
};

static const DeviceConfig PIXEL_9_PRO = {
    "Pixel 9 Pro", "caiman",
    "google/caiman/caiman:15/AP4A.250405.002/12833270:user/release-keys",
    -1, nullptr
};

static const DeviceConfig PIXEL_10_PRO = {
    "Pixel 10 Pro", "blazer",
    "google/blazer/blazer:16/BP41.250916.015.A1/14331773:user/release-keys",
    -1, nullptr
};

static bool isExcluded(const std::string& package) {
    static const char* const excluded[] = {
        "com.google.android.apps.recorder",
        "com.google.android.GoogleCamera",
        "com.google.android.apps.cameralite",
        "com.google.android.apps.motionsense.bridge",
        "com.google.android.gms.chimera",
        "com.google.android.gms.update",
        "com.android.camera",
        "com.google.android.xx",
    };
    for (const auto& s : excluded) {
        if (package.find(s) != std::string::npos) return true;
    }
    if (package.find("com.google.android.googlequicksearchbox:HotwordDetectionService") != std::string::npos) return true;
    if (package.find("com.google.android.googlequicksearchbox:trusted:") != std::string::npos) return true;
    if (package.find("com.google.android.apps.messaging:rcs") != std::string::npos) return true;
    return false;
}

static const DeviceConfig* resolveDevice(const std::string& package) {
    if (isExcluded(package)) return nullptr;

    if (package == "com.google.android.gms.unstable") {
        return &PIXEL_2;
    }

    if (package.find("com.google.android.apps.photos") != std::string::npos) {
        return &PIXEL_XL;
    }

    if (package == "com.google.pixel.livewallpaper" ||
        package == "com.breel.wallpaper" ||
        package == "com.snapchat.android" ||
        package == "com.google.process.gapps" ||
        package == "com.google.process.gservices" ||
        package == "com.adobe.lrmobile") {
        return &PIXEL_8_PRO;
    }

    if (package == "com.google.android.apps.subscriptions.red") {
        return &PIXEL_FOLD;
    }

    if (package.find("com.google.android.googlequicksearchbox") != std::string::npos) {
        return &PIXEL_8_PRO;
    }

    if (package == "com.google.ar.core" ||
        package == "com.google.vr.apps.ornament" ||
        package == "com.google.android.tts" ||
        package == "com.google.android.apps.wearables.maestro.companion" ||
        package == "com.nothing.smartcenter" ||
        package == "com.netflix.mediaclient") {
        return &PIXEL_5;
    }

    if (package == "com.google.android.gms") {
        return &PIXEL_8_PRO;
    }

    if (package.find("com.google") != std::string::npos) {
        return &PIXEL_6_PRO;
    }

    return nullptr;
}

static void writeStatus(int companion_fd, const char* pkg, const char* model) {
    if (companion_fd < 0) return;
    char buf[512];
    int len = snprintf(buf, sizeof(buf), "%s|%s", pkg, model);
    if (len > 0) {
        write(companion_fd, buf, len);
    }
    close(companion_fd);
}

class pixelify : public zygisk::ModuleBase {
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

        pkg_name = process;
        env->ReleaseStringUTFChars(args->nice_name, process);

        DEBUG = (access("/data/adb/modules/PixelifyNext/debug", F_OK) == 0);

        spoof_device = resolveDevice(pkg_name);

        if (!spoof_device) {
            api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
            return;
        }

        if (pkg_name == "com.google.android.gms.unstable") {
            api->setOption(zygisk::Option::FORCE_DENYLIST_UNMOUNT);
        }

        companion_fd = api->connectCompanion();

        if (DEBUG) {
            LOGI("Target: %s -> %s", pkg_name.c_str(), spoof_device->model);
        }
    }

    void postAppSpecialize(const AppSpecializeArgs *args) override {
        if (!spoof_device) return;

        injectProps(*spoof_device);
        writeStatus(companion_fd, pkg_name.c_str(), spoof_device->model);
        companion_fd = -1;
    }

private:
    Api *api = nullptr;
    JNIEnv *env = nullptr;
    const DeviceConfig* spoof_device = nullptr;
    std::string pkg_name;
    int companion_fd = -1;

    void setStaticString(jclass clazz, const char* field, const char* value) {
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

    void injectProps(const DeviceConfig& dev) {
        if (!env) return;

        jclass build = env->FindClass("android/os/Build");
        if (!build) {
            if (env->ExceptionCheck()) env->ExceptionClear();
            LOGW("Build class not found for %s", pkg_name.c_str());
            return;
        }

        setStaticString(build, "BRAND", "google");
        setStaticString(build, "MANUFACTURER", "Google");
        setStaticString(build, "PRODUCT", dev.product);
        setStaticString(build, "DEVICE", dev.product);
        setStaticString(build, "MODEL", dev.model);
        setStaticString(build, "TAGS", "release-keys");
        setStaticString(build, "TYPE", "user");
        setStaticString(build, "FINGERPRINT", dev.fingerprint);

        if (dev.hardware) {
            setStaticString(build, "HARDWARE", dev.hardware);
        }

        if (dev.sdk_version != -1) {
            injectSdkVersion(dev.sdk_version);
        }

        if (DEBUG) {
            LOGI("Injected: %s -> %s (%s)", pkg_name.c_str(), dev.model, dev.product);
        }
    }
};

static void companion_handler(int fd) {
    char buf[512] = {0};
    ssize_t n = read(fd, buf, sizeof(buf) - 1);
    if (n > 0) {
        buf[n] = '\0';
        int status_fd = open("/data/adb/modules/PixelifyNext/zygisk_status",
                            O_WRONLY | O_CREAT | O_TRUNC, 0644);
        if (status_fd >= 0) {
            write(status_fd, buf, n);
            write(status_fd, "\n", 1);
            close(status_fd);
        }
    }
    close(fd);
}

REGISTER_ZYGISK_MODULE(pixelify)
REGISTER_ZYGISK_COMPANION(companion_handler)
