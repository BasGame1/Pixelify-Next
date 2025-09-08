package com.pixelify.next.companion.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun AboutScreen() {
    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // App Logo Placeholder
        Text(
            text = "Pixelify Next Companion",
            style = MaterialTheme.typography.headlineMedium,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        Text(
            text = "Version 1.0.0", // Placeholder version
            style = MaterialTheme.typography.bodyMedium,
            modifier = Modifier.padding(bottom = 16.dp)
        )

        Spacer(modifier = Modifier.height(32.dp))

        Text(
            text = "Credits:",
            style = MaterialTheme.typography.titleMedium,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        Text(
            text = "Developed by BasGame1 & Gemini CLI", // give credits to gemini :) cli for helping with graddle
            style = MaterialTheme.typography.bodyMedium
        )
        Text(
            text = "Special thanks to the Pixelify community.",
            style = MaterialTheme.typography.bodyMedium
        )

        // TODO: Add update button functionality if needed
    }
}
