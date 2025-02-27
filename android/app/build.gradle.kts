plugins {
    id("com.android.application")
    id("kotlin-android")
<<<<<<< HEAD
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
=======
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase eklentisi
>>>>>>> 25036298 (v1)
}

android {
    namespace = "com.example.flutter_application2"
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
<<<<<<< HEAD
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_application2"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
=======
        applicationId = "com.example.flutter_application2"
>>>>>>> 25036298 (v1)
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
<<<<<<< HEAD
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
=======
>>>>>>> 25036298 (v1)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
<<<<<<< HEAD
}

dependencies {
    classpath 'com.google.gms:google-services:4.3.10'
}

=======
}:


dependencies {
    implementation 'com.google.firebase:firebase-firestore:24.0.0'  // Firestore için
    implementation 'com.google.firebase:firebase-auth:21.0.5'  // Authentication için
}
>>>>>>> 25036298 (v1)
