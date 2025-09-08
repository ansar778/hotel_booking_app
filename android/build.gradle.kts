// 1. First, define the buildscript which provides the classpath dependencies (CRUCIAL)
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // This is the classpath for the Android Gradle plugin
        classpath("com.android.tools.build:gradle:7.4.2") // Use your current version
        // This is the classpath for the Google Services plugin.
        // WITHOUT THIS LINE, the plugin in app/build.gradle.kts cannot be found!
        classpath("com.google.gms:google-services:4.3.15")
        // Classpath for Kotlin plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.0") // Use your current version
    }
}

// 2. Then, your allprojects block
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 3. Then, your other configuration (changing build directory, etc.)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}