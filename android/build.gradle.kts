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
    
    // Fix for dependencies missing namespace (AGP 8.0+)
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library")) {
            project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                if (namespace == null) {
                    // Set namespace for dependencies that don't specify one
                    // Based on the package names and common Flutter plugin patterns
                    namespace = when (project.name) {
                        "contacts_service" -> "github.clovisnicolas.flutter_contacts"
                        "flutter_sms" -> "com.babariviere.flutter_sms"
                        "device_calendar" -> "com.builttoroam.device_calendar"
                        "flutter_background" -> "de.julianassmann.flutter_background"
                        "flutter_alarm_clock" -> "com.medina.flutter_alarm_clock"
                        "flutter_sensors" -> "com.plugin.flutter_sensors"
                        else -> {
                            // Fallback: use group.name or project name
                            val fallbackNamespace = if (project.group.toString().isNotEmpty()) {
                                "${project.group}.${project.name}"
                            } else {
                                "com.example.${project.name}"
                            }
                            fallbackNamespace
                        }
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
