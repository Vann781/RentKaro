//plugins {
//    id("com.android.application")
//    // START: FlutterFire Configuration
//    id("com.google.gms.google-services")
//    // END: FlutterFire Configuration
//    id("kotlin-android")
//    id("dev.flutter.flutter-gradle-plugin")
//}
//
//android {
//    namespace = "com.example.rentkaro_frontend"
//    compileSdk = flutter.compileSdkVersion
//    ndkVersion = "27.0.12077973"
//
//    compileOptions {
//        sourceCompatibility = JavaVersion.VERSION_1_8
//        targetCompatibility = JavaVersion.VERSION_1_8
//        isCoreLibraryDesugaringEnabled = true
//    }
//    kotlinOptions {
//        jvmTarget = JavaVersion.VERSION_1_8.toString()
//    }
//
//    defaultConfig {
//        applicationId = "com.example.rentkaro_frontend"
//        minSdk = 23
//        targetSdk = 34
//        versionCode = flutter.versionCode
//        versionName = flutter.versionName
//    }
//
//    signingConfigs {
//        // NOTE: You would normally load key properties from a separate file here
//        create("release") {
//            // You MUST replace these placeholder values with your actual keystore details
//            keyAlias = "your_key_alias"
//            keyPassword = "your_key_password"
//            storeFile = file("path/to/your/keystore.jks") // Change path
//            storePassword = "your_store_password"
//        }
//    }
//
//
//    buildTypes {
//        release {
//            isMinifyEnabled = true
//            isShrinkResources = true
//            proguardFiles(
//                getDefaultProguardFile("proguard-android-optimize.txt"),
//                "proguard-rules.pro"
//            )
//            signingConfig = signingConfigs.getByName("release")
//        }
//    }
//}
//
//flutter {
//    source = "../.."
//}
//
//// --- FIX: DEPENDENCIES BLOCK MOVED TO CORRECT LOCATION (OUTSIDE 'android') ---
//dependencies {
//    // This provides the necessary Java 8+ features for the local notifications package
//    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
//}
//// --- END FIX ---



import java.util.Properties
import java.io.FileInputStream

// --- 1. LOAD THE KEYSTORE PROPERTIES FILE (located in the android/ directory) ---
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    // Read the key.properties file into the keystoreProperties object
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.rentkaro_frontend"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        applicationId = "com.example.rentkaro_frontend"
        minSdk = 23
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    signingConfigs {
        // --- 2. CREATE RELEASE CONFIG USING LOADED PROPERTIES ---
        create("release") {
            // Read values directly from the loaded Properties object
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String

            // File must be correctly referenced using the path from key.properties
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }


    buildTypes {
        release {
            isMinifyEnabled = true  // <-- CHANGE THIS TO FALSE
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Use the fully defined release signing config
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // --- ADD MULTIDEX DEPENDENCY HERE ---
    implementation("androidx.multidex:multidex:2.0.1")
}