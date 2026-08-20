#include <cstdlib>
#include <unistd.h>
#include <fcntl.h>
#include <string>
#include <vector>
#include <android/log.h>
#include <cstring>
#include <cstdio>

#include "module.h"
#include "zygisk.hpp"

using zygisk::Api;
using zygisk::AppSpecializeArgs;
using zygisk::ServerSpecializeArgs;

static bool DEBUG = false;

static constexpr const char* CONFIG_PATH = "/data/adb/modules/PixelifyNext/spoof_config";
static constexpr const char* STATUS_PATH = "/data/adb/modules/PixelifyNext/zygisk_status";

struct DeviceConfig {
    const char* key;
    const char* model;
    const char* product;
    const char* fingerprint;
    int sdk_version;
    const char* hardware;
};

static const DeviceConfig DEVICES[] = {
    {"pixel_xl", "Pixel XL", "marlin",
     "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys",
     34, nullptr},
    {"pixel_2", "Pixel 2", "walleye",
     "google/walleye/walleye:8.1.0/OPM1.171019.011/4448085:user/release-keys",
     27, nullptr},
    {"pixel_5", "Pixel 5", "redfin",
     "google/redfin/redfin:14/AP2A.240805.005/12025142:user/release-keys",
     -1, nullptr},
    {"pixel_6_pro", "Pixel 6 Pro", "raven",
     "google/raven/raven:14/AP2A.240805.005/12025142:user/release-keys",
     -1, nullptr},
    {"pixel_7_pro", "Pixel 7 Pro", "cheetah",
     "google/cheetah/cheetah:14/AP2A.240805.005/12025142:user/release-keys",
     -1, nullptr},
    {"pixel_fold", "Pixel Fold", "felix",
     "google/felix/felix:14/AP2A.240805.005/12025142:user/release-keys",
     -1, "felix"},
    {"pixel_8_pro", "Pixel 8 Pro", "husky",
     "google/husky/husky:14/AP2A.240805.005/12025142:user/release-keys",
     -1, nullptr},
    {"pixel_9_pro", "Pixel 9 Pro", "caiman",
     "google/caiman/caiman:15/AP4A.250405.002/12833270:user/release-keys",
     -1, nullptr},
    {"pixel_10_pro", "Pixel 10 Pro", "blazer",
     "google/blazer/blazer:16/BP41.250916.015.A1/14331773:user/release-keys",
     -1, nullptr},
};

static constexpr int DEVICE_COUNT = sizeof(DEVICES) / sizeof(DEVICES[0]);

static const DeviceConfig* findByKey(const char* key) {
    for (int i = 0; i < DEVICE_COUNT; i++) {
        if (strcmp(DEVICES[i].key, key) == 0) return &DEVICES[i];
    }
    return nullptr;
}

static const DeviceConfig* PIXEL_XL()    { return &DEVICES[0]; }
static const DeviceConfig* PIXEL_2()     { return &DEVICES[1]; }
static const DeviceConfig* PIXEL_5()     { return &DEVICES[2]; }
static const DeviceConfig* PIXEL_6_PRO() { return &DEVICES[3]; }
static const DeviceConfig* PIXEL_FOLD()  { return &DEVICES[5]; }
static const DeviceConfig* PIXEL_8_PRO() { return &DEVICES[6]; }
static const DeviceConfig* PIXEL_10_PRO(){ return &DEVICES[8]; }

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

static const DeviceConfig* defaultDevice(const std::string& package) {
    if (isExcluded(package)) return nullptr;

    if (package == "com.google.android.gms.unstable") {
        return PIXEL_2();
    }

    if (package.find("com.google.android.apps.photos") != std::string::npos) {
        return PIXEL_XL();
    }

    if (package == "com.google.android.aicore" ||
        package == "com.google.android.apps.aicore" ||
        package == "com.google.android.apps.bard" ||
        package == "com.google.android.apps.customization.pixel" ||
        package == "com.google.android.apps.pixel.agent" ||
        package == "com.google.android.apps.pixel.creativeassistant" ||
        package == "com.google.android.as" ||
        package == "com.google.android.apps.aiwallpapers") {
        return PIXEL_10_PRO();
    }

    if (package == "com.google.pixel.livewallpaper" ||
        package == "com.breel.wallpaper" ||
        package == "com.snapchat.android" ||
        package == "com.google.process.gapps" ||
        package == "com.google.process.gservices" ||
        package == "com.adobe.lrmobile") {
        return PIXEL_8_PRO();
    }

    if (package == "com.google.android.apps.subscriptions.red") {
        return PIXEL_FOLD();
    }

    if (package.find("com.google.android.googlequicksearchbox") != std::string::npos) {
        return PIXEL_8_PRO();
    }

    if (package == "com.google.ar.core" ||
        package == "com.google.vr.apps.ornament" ||
        package == "com.google.android.tts" ||
        package == "com.google.android.apps.wearables.maestro.companion" ||
        package == "com.nothing.smartcenter" ||
        package == "com.netflix.mediaclient") {
        return PIXEL_5();
    }

    if (package == "com.google.android.gms") {
        return PIXEL_8_PRO();
    }

    if (package.find("com.google") != std::string::npos) {
        return PIXEL_6_PRO();
    }

    return nullptr;
}

enum CompanionAction : uint8_t {
    ACTION_RESOLVE = 1,
    ACTION_STATUS  = 2,
};

struct CompanionRequest {
    uint8_t action;
    uint16_t pkg_len;
};

struct CompanionResolveReply {
    int8_t device_index;
};

static bool readFull(int fd, void* buf, size_t len) {
    size_t done = 0;
    while (done < len) {
        ssize_t n = read(fd, (char*)buf + done, len - done);
        if (n <= 0) return false;
        done += n;
    }
    return true;
}

static bool writeFull(int fd, const void* buf, size_t len) {
    size_t done = 0;
    while (done < len) {
        ssize_t n = write(fd, (const char*)buf + done, len - done);
        if (n <= 0) return false;
        done += n;
    }
    return true;
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

        if (isExcluded(pkg_name)) {
            api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
            return;
        }

        int resolve_fd = api->connectCompanion();
        if (resolve_fd >= 0) {
            spoof_device = resolveViaCompanion(resolve_fd, pkg_name);
            close(resolve_fd);
        }

        if (!spoof_device) {
            spoof_device = defaultDevice(pkg_name);
        }

        if (!spoof_device) {
            api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
            return;
        }

        if (pkg_name == "com.google.android.gms.unstable") {
            api->setOption(zygisk::Option::FORCE_DENYLIST_UNMOUNT);
        }

        if (DEBUG) {
            LOGI("Target: %s -> %s", pkg_name.c_str(), spoof_device->model);
        }
    }

    void postAppSpecialize(const AppSpecializeArgs *args) override {
        if (!spoof_device) return;

        injectProps(*spoof_device);

        int status_fd = api->connectCompanion();
        if (status_fd >= 0) {
            sendStatus(status_fd, pkg_name, spoof_device->model);
            close(status_fd);
        }
    }

private:
    Api *api = nullptr;
    JNIEnv *env = nullptr;
    const DeviceConfig* spoof_device = nullptr;
    std::string pkg_name;

    const DeviceConfig* resolveViaCompanion(int fd, const std::string& pkg) {
        CompanionRequest req = {};
        req.action = ACTION_RESOLVE;
        req.pkg_len = (uint16_t)pkg.size();
        if (!writeFull(fd, &req, sizeof(req))) return nullptr;
        if (!writeFull(fd, pkg.c_str(), pkg.size())) return nullptr;

        CompanionResolveReply reply = {};
        if (!readFull(fd, &reply, sizeof(reply))) return nullptr;

        if (reply.device_index >= 0 && reply.device_index < DEVICE_COUNT) {
            return &DEVICES[reply.device_index];
        }
        return nullptr;
    }

    void sendStatus(int fd, const std::string& pkg, const char* model) {
        CompanionRequest req = {};
        req.action = ACTION_STATUS;
        std::string payload = pkg + "|" + model;
        req.pkg_len = (uint16_t)payload.size();
        if (!writeFull(fd, &req, sizeof(req))) return;
        writeFull(fd, payload.c_str(), payload.size());
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

static int8_t lookupConfigOverride(const std::string& pkg) {
    FILE* f = fopen(CONFIG_PATH, "r");
    if (!f) return -1;

    char line[512];
    while (fgets(line, sizeof(line), f)) {
        if (line[0] == '#' || line[0] == '\n') continue;

        char* eq = strchr(line, '=');
        if (!eq) continue;

        *eq = '\0';
        char* key = eq + 1;
        size_t klen = strlen(key);
        if (klen > 0 && key[klen - 1] == '\n') key[klen - 1] = '\0';

        if (pkg == line) {
            if (strcmp(key, "none") == 0 || strcmp(key, "skip") == 0) {
                fclose(f);
                return -2;
            }
            for (int i = 0; i < DEVICE_COUNT; i++) {
                if (strcmp(DEVICES[i].key, key) == 0) {
                    fclose(f);
                    return (int8_t)i;
                }
            }
        }
    }
    fclose(f);
    return -1;
}

static void companion_handler(int fd) {
    CompanionRequest req = {};
    if (!readFull(fd, &req, sizeof(req))) return;

    if (req.pkg_len > 500) return;

    char buf[512] = {0};
    if (req.pkg_len > 0) {
        if (!readFull(fd, buf, req.pkg_len)) return;
        buf[req.pkg_len] = '\0';
    }

    if (req.action == ACTION_RESOLVE) {
        std::string pkg(buf, req.pkg_len);
        CompanionResolveReply reply = {};
        reply.device_index = lookupConfigOverride(pkg);
        writeFull(fd, &reply, sizeof(reply));
    } else if (req.action == ACTION_STATUS) {
        int status_fd = open(STATUS_PATH, O_WRONLY | O_CREAT | O_TRUNC, 0644);
        if (status_fd >= 0) {
            write(status_fd, buf, req.pkg_len);
            write(status_fd, "\n", 1);
            close(status_fd);
        }
    }
}

REGISTER_ZYGISK_MODULE(pixelify)
REGISTER_ZYGISK_COMPANION(companion_handler)
