plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firebase settings for "your order is ready" pushes, from
// apps/mobile/firebase.json (see the README). The Dart side reads the same
// file with --dart-define-from-file. Without it the app builds with pushes off.
val firebase: Map<String, String>? =
    rootProject.file("../firebase.json").takeIf { it.exists() }?.let {
        @Suppress("UNCHECKED_CAST")
        groovy.json.JsonSlurper().parse(it) as Map<String, String>
    }

android {
    namespace = "com.codingspacekh.homecoffee"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.codingspacekh.homecoffee"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // What google-services.json would provide, so Firebase starts with the
        // app and can show a push even when the app isn't running
        firebase?.let {
            resValue("string", "google_app_id", it.getValue("FIREBASE_ANDROID_APP_ID"))
            resValue("string", "google_api_key", it.getValue("FIREBASE_ANDROID_API_KEY"))
            resValue("string", "gcm_defaultSenderId", it.getValue("FIREBASE_SENDER_ID"))
            resValue("string", "project_id", it.getValue("FIREBASE_PROJECT_ID"))
        }
    }

    buildFeatures {
        resValues = true
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
