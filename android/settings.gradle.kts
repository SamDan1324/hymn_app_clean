pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val propertiesFile = file("local.properties")
        if (propertiesFile.exists()) {
            properties.load(propertiesFile.inputStream())
        }
        val sdkPath = properties.getProperty("flutter.sdk")
        if (sdkPath != null) return@run sdkPath
        val envSdkPath = System.getenv("FLUTTER_ROOT")
        if (envSdkPath != null) return@run envSdkPath
        throw GradleException("Flutter SDK not found")
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
}

include(":app")