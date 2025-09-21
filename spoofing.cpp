#include "zygisk.hpp"
#include <string>
#include <fstream>
#include <vector>
#include <map>
#include <unistd.h> // For the 'access' function
#include <sys/system_properties.h>
#include "dobby.h"

using zygisk::Api;
using zygisk::AppSpecializeArgs;

// Helper function to check if a file exists
bool file_exists(const std::string& name) {
    return (access(name.c_str(), F_OK) != -1);
}

// ... (All other functions remain the same as the last version) ...
// - my_system_property_get(...)
// - my_IsPixelExperienceEnabled()
// - apply_gphotos_hooks()
// - load_spoof_rules_for_app(...)

class MyModule : public zygisk::ModuleBase {
public:
    void onLoad(Api *api) override {
        this->api = api;
    }

    void preAppSpecialize(AppSpecializeArgs *args) override {
        const char* process = api->getAppName();
        std::string process_str(process);
        
        // --- 1. Check for and apply GENERAL device spoofing ---
        // IMPORTANT: Replace "your_module_id" with your actual module's ID
        std::string spoof_conf_path = "/data/adb/modules/your_module_id/spoof.conf";

        if (file_exists(spoof_conf_path)) {
            // spoof.conf exists, so load the rules for the current app
            std::map<std::string, std::string> spoof_properties;
            load_spoof_rules_for_app(process_str, spoof_properties, spoof_conf_path);

            // If any rules were found for this app, apply the property hook
            if (!spoof_properties.empty()) {
                api->log("ZygiskSpoof: Applying %zu property spoofs for %s", spoof_properties.size(), process);
                // Hook logic using Dobby...
            }
        }

        // --- 2. Check for and apply GOOGLE PHOTOS patch ---
        std::string gphotos_conf_path = "/data/adb/modules/your_module_id/gphotos.conf";
        
        // This patch only runs if gphotos.conf exists AND the current app is Google Photos
        if (file_exists(gphotos_conf_path) && process_str == "com.google.android.apps.photos") {
            api->log("ZygiskSpoof: Google Photos patch enabled. Applying feature flag hooks.");
            
            // First, ensure Pixel XL props are spoofed for GPhotos, even if not in main spoof.conf
            // This is a robust way to ensure the GPhotos patch works standalone.
            // (You would add logic here to apply Pixel XL props)
            
            // Then, apply the special feature flag hook.
            apply_gphotos_hooks();
        }
    }

private:
    Api *api;
};

REGISTER_ZYGISK_MODULE(Spoofing)