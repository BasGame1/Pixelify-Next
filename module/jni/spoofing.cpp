// This is your jni/my_module.cpp file
#include "zygisk.hpp"
#include <string>
#include <fstream>
#include <vector>
#include <map>
#include <sys/system_properties.h>
#include "Dobby/dobby.h"  

using zygisk::Api;
using zygisk::AppSpecializeArgs;

// This map will hold our spoofing rules, e.g., {"ro.product.model", "Pixel 8 Pro"}
static std::map<std::string, std::string> g_spoof_properties;

// Our replacement function that provides the fake properties
int my_system_property_get(const char* name, char* value) {
    std::string prop_name(name);

    // Check if the property being requested is in our spoofing list
    if (g_spoof_properties.count(prop_name)) {
        const char* spoof_value = g_spoof_properties[prop_name].c_str();
        strcpy(value, spoof_value);
        return strlen(spoof_value);
    }

    // If not, call the original function (this is a placeholder, Dobby will fill it)
    return __system_property_get(name, value);
}

class MyModule : public zygisk::ModuleBase {
public:
    void onLoad(Api *api) override {
        this->api = api;
    }

    void preAppSpecialize(AppSpecializeArgs *args) override {
        const char* process = api->getAppName();
        
        // Clear previous rules before checking the new app
        g_spoof_properties.clear();

        // Read the config file to see if we need to spoof this app
        load_spoof_rules_for_app(process);

        // If we found any rules for this app, apply the hooks
        if (!g_spoof_properties.empty()) {
            api->log("ZygiskSpoof: Found %zu rules for %s. Applying hooks.", g_spoof_properties.size(), process);
            DobbyHook(
                (void *)__system_property_get,
                (void *)my_system_property_get,
                nullptr // No need to store the original, Dobby handles it or we can call it directly
            );
        }
    }

private:
    Api *api;

    // This function reads our simple text file
    void load_spoof_rules_for_app(const std::string& app_name) {
        // IMPORTANT: Replace "your_module_id" with your actual module's ID from module.prop
        std::ifstream file("/data/adb/modules/PixelifyNext/spoof.conf");
        std::ifstream file("/data/adb/ksu/modules/PixelifyNext/spoof.conf");
        std::string line;
        bool in_target_section = false;

        while (std::getline(file, line)) {
            // Check if we are entering a new app section
            if (line[0] == '[' && line.back() == ']') {
                std::string section_name = line.substr(1, line.length() - 2);
                in_target_section = (section_name == app_name);
            } else if (in_target_section) {
                // If we are in the correct app section, parse the key=value rules
                size_t separator = line.find('=');
                if (separator != std::string::npos) {
                    std::string key = line.substr(0, separator);
                    std::string value = line.substr(separator + 1);
                    g_spoof_properties[key] = value;
                }
            }
        }
    }
};

REGISTER_ZYGISK_MODULE(MyModule)
