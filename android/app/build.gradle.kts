import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.voicevibe"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    lint {
        baseline = file("lint-baseline.xml")
    }

    defaultConfig {
        applicationId = "com.example.voicevibe"
        minSdk = 30
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("keystore.properties")
            if (keystorePropertiesFile.exists()) {
                val propertiesMap = mutableMapOf<String, String>()
                keystorePropertiesFile.readLines().forEach { line ->
                    val trimmedLine = line.trim()
                    if (trimmedLine.isNotEmpty() && !trimmedLine.startsWith("#")) {
                        val parts = trimmedLine.split("=", limit = 2)
                        if (parts.size == 2) {
                            propertiesMap[parts[0].trim()] = parts[1].trim()
                        }
                    }
                }

                storeFile = file(propertiesMap["storeFile"] ?: throw GradleException("Missing storeFile in keystore.properties"))
                storePassword = propertiesMap["storePassword"] ?: throw GradleException("Missing storePassword in keystore.properties")
                keyAlias = propertiesMap["keyAlias"] ?: throw GradleException("Missing keyAlias in keystore.properties")
                keyPassword = propertiesMap["keyPassword"] ?: throw GradleException("Missing keyPassword in keystore.properties")

            } else {
                println("WARNING: keystore.properties not found. Release build will fail without signing config.")
            }
        }
    }

    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    packaging {
        resources {
            excludes.add("/META-INF/{AL2.0,LGPL2.1}")
        }
    }
}

configurations.all {
    resolutionStrategy {
        force("androidx.work:work-runtime:2.8.1")
        force("androidx.work:work-runtime-ktx:2.8.1")
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.1.0")
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("com.google.android.material:material:1.12.0")
    flutter {
        source = "../.."
    }
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
