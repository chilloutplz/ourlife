plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.unclebob.ourlife"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.unclebob.ourlife"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ✅ 서명 설정
    signingConfigs {
        create("release") {
            storeFile = file("c:/Projects/keys/ourlife-release.jks")
            storePassword = "Vari3112##"
            keyAlias = "ourlife"
            keyPassword = "Vari3112##"
        }
    }

    // ✅ 빌드 타입 정의
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")

            // ✅ Java/Kotlin 코드 난독화 및 리소스 축소 활성화
            isMinifyEnabled = true
            isShrinkResources = true

            // ✅ ProGuard 설정 파일 사용
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

}

flutter {
    source = "../.."
}
