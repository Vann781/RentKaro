//allprojects {
//    repositories {
//        google()
//        mavenCentral()
//    }
//}
//
//val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
//rootProject.layout.buildDirectory.value(newBuildDir)
//
//subprojects {
//    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
//    project.layout.buildDirectory.value(newSubprojectBuildDir)
//}
//subprojects {
//    project.evaluationDependsOn(":app")
//}
//
//tasks.register<Delete>("clean") {
//    delete(rootProject.layout.buildDirectory)
//}

// android/build.gradle.kts

buildscript {
    // This is where you declare dependencies for the Gradle build system itself.
    // We add the desugaring library here so it can be used in the app-level file.

    // Ensure the repositories are defined (they are implicitly here, but explicitly adding is safer)
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // You would typically have existing dependencies here, e.g.:
        // classpath("com.android.tools.build:gradle:7.3.0")

        // --- CRITICAL FIX: ADD DESUGARING LIBRARY CLASSPATH ---
        // This makes the desugaring library available for the app module to use.
        classpath("com.android.tools:desugar_jdk_libs:2.1.4")

    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

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