plugins {
    id("com.android.application")
    // Google Services / Crashlytics Gradle plugins are deliberately NOT applied
    // (spec 050, [L6]). `flutterfire configure` re-adds them on every run —
    // strip the "FlutterFire Configuration" block again when it does.
    // Consequence: google-services.json is never read at build time, so the
    // package_name <-> applicationId check lives only in the R11 test.
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "kz.qorzhyn"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // No applicationId here on purpose: each product flavor sets its own,
        // so an unflagged build fails instead of silently producing one of the
        // two apps. See ai_specs/archive/050-android-app-flavors-spec.md (R1, R13).
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Flavor names mirror the members of PushAudience
    // (lib/src/features/notifications/domain/push_audience.dart): adding a
    // third build changes both lists together.
    flavorDimensions += "app"

    productFlavors {
        create("client") {
            dimension = "app"
            applicationId = "kz.qorzhyn.app"
            // Resolved into android:label; a second AndroidManifest.xml per
            // flavor would drift on every permission added to only one of them.
            manifestPlaceholders["appLabel"] = "Qorzhyn"
        }
        create("business") {
            dimension = "app"
            applicationId = "kz.qorzhyn.business"
            manifestPlaceholders["appLabel"] = "Qorzhyn Business"
        }
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
