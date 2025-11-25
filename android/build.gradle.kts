plugins {
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
    id("com.google.gms.google-services") apply false
    id("dev.flutter.flutter-plugin-loader") apply false
}

val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    layout.buildDirectory.value(newSubprojectBuildDir)
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}