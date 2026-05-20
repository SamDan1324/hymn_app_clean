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
        listOf("/flutter", "/opt/flutter", "/home/user/flutter").forEach { path ->
            if (java.io.File(path).exists()) return@run path
        }
        throw GradleException("Flutter SDK not found")
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

rootProject.name = "hymn_app_clean"
include(":app")