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
                    when (project.name) {
                        "contacts_service" -> namespace = "github.clovisnicolas.flutter_contacts"
                        else -> {
                            // Fallback: use group.name or a generic namespace
                            val fallbackNamespace = project.group.toString().ifEmpty { "com.example" } + "." + project.name
                            namespace = fallbackNamespace
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
