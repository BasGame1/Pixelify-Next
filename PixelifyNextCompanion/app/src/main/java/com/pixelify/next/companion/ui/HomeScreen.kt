package com.pixelify.next.companion.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.material3.MaterialTheme
import com.pixelify.next.companion.RootUtil

data class ModuleFeature(val name: String, val configKey: String, val description: String)

@Composable
fun HomeScreen() {
    val features = remember { mutableStateOf(emptyList<ModuleFeature>()) }

    // Initialize features and their states
    val initialFeatures = listOf(
        ModuleFeature("Unlimited Google Photos", "ENABLE_PHOTOS_UNLIMITED", "Enables unlimited original quality Google Photos backup."),
        ModuleFeature("Pixel Launcher", "ENABLE_PIXEL_LAUNCHER", "Enables Pixel Launcher features."),
        ModuleFeature("Now Playing", "ENABLE_NOW_PLAYING", "Enables Now Playing feature."),
        ModuleFeature("Google Sans Fonts", "GSAN_FONT", "Enables Google Sans fonts system-wide."),
        ModuleFeature("Google Bootanimation", "ENABLE_BOOTANIMATION", "Enables Pixel bootanimation."),
        ModuleFeature("Google Dialer Features", "ENABLE_DIALER_FEATURES", "Enables Call Screening, Call Recording, etc."),
        ModuleFeature("Next Generation Assistant", "ENABLE_NGA", "Enables Next Generation Assistant features."),
        ModuleFeature("Google Settings Intelligence", "ENABLE_GSI", "Enables Google Settings Intelligence features.")
    )

    // Read initial states from config.prop
    // This should ideally be done in a ViewModel and observed
    val featureStates = remember { mutableStateOf(mutableMapOf<String, Boolean>()) }

    // This effect will run once when the composable is first launched
    // and update the states based on config.prop
    // In a real app, this would be handled by a ViewModel observing changes
    // and updating the UI state.
    androidx.compose.runtime.LaunchedEffect(Unit) {
        val states = mutableMapOf<String, Boolean>()
        initialFeatures.forEach { feature ->
            val value = RootUtil.readModuleConfig(feature.configKey)
            states[feature.configKey] = value == "1"
        }
        featureStates.value = states
        features.value = initialFeatures
    }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text(text = "Control Module Features", style = MaterialTheme.typography.headlineMedium, modifier = Modifier.padding(bottom = 16.dp))

        LazyColumn {
            items(features.value) { feature ->
                FeatureToggleCard(feature = feature, isChecked = featureStates.value[feature.configKey] ?: false) {
                    // Update state in UI immediately
                    val newStates = featureStates.value.toMutableMap()
                    newStates[feature.configKey] = it
                    featureStates.value = newStates

                    // Write to config.prop using RootUtil
                    // This should ideally be debounced or batched
                    RootUtil.writeModuleConfig(feature.configKey, if (it) "1" else "0")
                    // TODO: Inform user to reboot for changes to take effect or trigger a soft reboot
                }
            }
        }
    }
}

@Composable
fun FeatureToggleCard(feature: ModuleFeature, isChecked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(text = feature.name, style = MaterialTheme.typography.titleMedium)
                Text(text = feature.description, style = MaterialTheme.typography.bodySmall)
            }
            Switch(
                checked = isChecked,
                onCheckedChange = onCheckedChange
            )
        }
    }
}