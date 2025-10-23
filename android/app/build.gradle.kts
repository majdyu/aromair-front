plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.front_erp_aromair"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.front_erp_aromair"
        // ⚠️ Ensure minSdk >= 21 for desugaring (Flutter default is usually 21)
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: replace with your real signing config before publishing
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            isDebuggable = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Required for desugaring (Kotlin DSL syntax)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    // Not strictly required because the Flutter plugin pulls them in,
    // but harmless if you keep them out. Leave Firebase deps to Flutter plugins.
    // implementation(platform("com.google.firebase:firebase-bom:33.3.0"))
    // implementation("com.google.firebase:firebase-messaging")
    implementation("androidx.core:core-ktx:1.13.1")
}
