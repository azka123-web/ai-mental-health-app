buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.4")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ---------------------
// Custom Build Directory
// ---------------------
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()

rootProject.layout.buildDirectory.value(newBuildDir)

// ---------------------
// Subprojects Configuration
// ---------------------
subprojects {
    // Change subproject build directory
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")

    // Enable BuildConfig and set namespace for android modules
    extensions.findByName("android")?.let { androidExt ->
        when (androidExt) {
            is com.android.build.gradle.LibraryExtension -> {
                androidExt.buildFeatures.buildConfig = true
                // optional temporary namespace for libraries
                androidExt.namespace = "com.example.${project.name}"
            }
            is com.android.build.gradle.AppExtension -> {
                androidExt.buildFeatures.buildConfig = true
            }
        }
    }
}

// ---------------------
// Clean Task
// ---------------------
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
