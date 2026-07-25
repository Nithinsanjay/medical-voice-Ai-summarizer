import com.android.build.gradle.BaseExtension
import com.android.build.gradle.LibraryExtension

buildscript {
    val kotlinVersion: String by extra("2.2.20")
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven(url = "https://www.jitpack.io")
    }
}

subprojects {
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin" &&
                requested.name.startsWith("kotlin")) {
                useVersion("2.2.20")
            }
        }
    }

    plugins.withId("com.android.application") {
        extensions.configure<BaseExtension>("android") {
            ndkVersion = "28.2.13676358"
        }
    }

    plugins.withId("com.android.library") {
        extensions.configure<LibraryExtension>("android") {
            ndkVersion = "28.2.13676358"
        }
    }
}

extra["kotlin.version"] = "2.2.20"

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}