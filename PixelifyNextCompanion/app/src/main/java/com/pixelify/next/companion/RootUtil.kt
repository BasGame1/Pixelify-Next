package com.pixelify.next.companion

import android.util.Log
import java.io.DataOutputStream
import java.io.File

object RootUtil {

    private const val TAG = "RootUtil"
    private const val MODULE_PATH = "/data/adb/modules/Pixelify"

    fun executeCommand(command: String): String {
        var output = ""
        try {
            val process = Runtime.getRuntime().exec("su")
            val os = DataOutputStream(process.outputStream)
            os.writeBytes(command + "\n")
            os.writeBytes("exit\n")
            os.flush()
            process.waitFor()

            val inputStream = process.inputStream
            val errorStream = process.errorStream

            output = inputStream.bufferedReader().use { it.readText() }
            val errorOutput = errorStream.bufferedReader().use { it.readText() }

            if (errorOutput.isNotEmpty()) {
                Log.e(TAG, "Command error: $errorOutput")
                output += "\nError: $errorOutput"
            }

        } catch (e: Exception) {
            Log.e(TAG, "Error executing command: ", e)
            output = "Error: ${e.message}"
        }
        return output
    }

    fun isRooted(): Boolean {
        return executeCommand("echo hello").contains("hello")
    }

    fun readModuleConfig(propertyName: String): String? {
        val configFile = File("$MODULE_PATH/config.prop")
        if (!configFile.exists()) {
            Log.e(TAG, "Config file not found: ${configFile.absolutePath}")
            return null
        }
        val content = executeCommand("cat ${configFile.absolutePath}")
        val regex = "^\\s*#?\\s*" + Regex.escape(propertyName) + "\\s*=\\s*(.*)$".toRegex(RegexOption.MULTILINE)
        val match = regex.find(content)
        return match?.groups?.get(1)?.value?.trim()
    }

        fun writeModuleConfig(propertyName: String, value: String): Boolean {
        val configFile = File("$MODULE_PATH/config.prop")
        if (!configFile.exists()) {
            Log.e(TAG, "Config file not found: ${configFile.absolutePath}")
            return false
        }

        // Use sed to update or add the property
        // -i: in-place editing
        // s/^#?\s*propertyName\s*=.*/propertyName=value/: find and replace existing line (commented or not)
        // $a\propertyName=value: if not found, append at the end
        val command = "sed -i '/^#?\s*${propertyName}\s*=.*/c\${propertyName}=${value}' ${configFile.absolutePath} || sed -i '\$a\${propertyName}=${value}' ${configFile.absolutePath}"
        val result = executeCommand(command)

        // Check if the command was successful
        return result.isEmpty() || !result.contains("Error")
    }
}
