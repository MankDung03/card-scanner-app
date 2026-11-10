plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_scanner_card"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Application ID as specified in A51 requirement
        applicationId = "com.example.app_scanner_card"
        minSdk = 24 // Android 7.0+ as specified in A51 requirement
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Bundled Japanese Text Recognition model (100% On-device offline, không tải qua mạng)
    implementation("com.google.mlkit:text-recognition-japanese:16.0.1")
    // Bundled Latin Text Recognition model (100% On-device offline, tiếng Việt & Latin)
    implementation("com.google.mlkit:text-recognition:16.0.1")
}
