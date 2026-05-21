allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// gradle.afterProject fires per-project immediately after its build script
// finishes, before task configuration — safe to override compileSdk here.
// Forces file_picker 8.x (hardcoded at 34) to 36 so the
// flutter_plugin_android_lifecycle AAR metadata check passes.
gradle.afterProject {
    extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
        compileSdkVersion(36)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
