package com.pixelify.next.companion.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.pixelify.next.companion.RootUtil
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FlagsScreen() {
    var flagName by remember { mutableStateOf("") }
    var flagValue by remember { mutableStateOf("") }
    val flags = remember { mutableStateListOf<Pair<String, String>>() }

    // Function to load flags
    val loadFlags: () -> Unit = {
        LaunchedEffect(Unit) {
            withContext(Dispatchers.IO) {
                val output = RootUtil.executeCommand("settings list global")
                val parsedFlags = output.lines().mapNotNull { line ->
                    val parts = line.split("=", limit = 2)
                    if (parts.size == 2) parts[0] to parts[1] else null
                }
                flags.clear()
                flags.addAll(parsedFlags)
            }
        }
    }

    // Load flags when the screen is first composed
    LaunchedEffect(Unit) {
        loadFlags()
    }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text(text = "Flags Screen - Manage Google Services Flags", style = MaterialTheme.typography.headlineMedium, modifier = Modifier.padding(bottom = 16.dp))

        OutlinedTextField(
            value = flagName,
            onValueChange = { flagName = it },
            label = { Text("Flag Name") },
            modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp)
        )

        OutlinedTextField(
            value = flagValue,
            onValueChange = { flagValue = it },
            label = { Text("Flag Value") },
            modifier = Modifier.fillMaxWidth().padding(bottom = 16.dp)
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceAround
        ) {
            Button(onClick = {
                RootUtil.executeCommand("settings put global $flagName $flagValue")
                loadFlags() // Refresh flags after setting
            }) {
                Text("Set Flag")
            }

            Button(onClick = {
                RootUtil.executeCommand("settings delete global $flagName")
                loadFlags() // Refresh flags after deleting
            }) {
                Text("Delete Flag")
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Text(text = "Existing Flags:", style = MaterialTheme.typography.titleMedium, modifier = Modifier.padding(bottom = 8.dp))

        LazyColumn {
            items(flags) { (name, value) ->
                Text("$name = $value")
            }
        }
    }
}
