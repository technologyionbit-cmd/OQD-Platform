plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.aqd.ionbit.aqd_ionbit"
    // flutter_secure_storage / path_provider / shared_preferences prefer
    // compileSdk 36, which Flutter surfaces as a build warning (not an
    // error — AGP compiling against a lower, backward-compatible SDK still
    // produces a working build). Left at the Flutter tool's own default
    // here because SDK Platform 36 is not available in every build
    // environment (e.g. offline/bandwidth-limited CI); bump to 36 once
    // it's present locally. ndkVersion IS pinned — all three plugins agree
    // on 27.0.12077973 and it's a small, already-cached download.
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.aqd.ionbit.aqd_ionbit"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // flutter_secure_storage requires API 23+ (AndroidKeyStore APIs
        // aren't available below that) — tokens are never stored anywhere
        // else, so this floor is non-negotiable, not just Flutter's default.
        minSdk = 23
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

flutter {
    source = "../.."
}
