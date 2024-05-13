---
title: "A beautiful workaround for accessing Gradle Version Catalogs from Precompiled Script Plugins"
# slug: "" # if :slug is in the permalinks configuration, use this to resolve URL conflict with other posts
date: 2024-05-12T14:52:55Z # if year month day in the permalinks configuration and other posts have the same date, modify this to resolve URL conflict with other posts 
lastmod: 2024-05-12T14:52:55Z # no longer needed if enableGitInfo = true
draft: true # remember to change it back to false before opening the PR for publishing
authors: [CXwudi] # no quotes
featuredImage: "img/featured image.webp"
description: "Using the gradle-buildconfig-plugin or the BuildKonfig plugin to access Gradle Version Catalogs from precompiled script plugins"
# license: '<a rel="license external nofollow noopener noreffer" href="https://creativecommons.org/licenses/by/4.0/" target="_blank">CC BY 4.0</a>'

# need quotes for all three
tags: [devops]
categories: [tech]
series: []
series_weight: 

# you can copy any config from [params.page] to here to override global default

# outdatedArticleReminder: # uncomment to enable, default is false in config 
  # enable: true
  # reminder: 180
  # warning: 365
sponsor:
  enable: true
  bio: "Ahh, I feel so tired 😫 after writing this post. I need a cup of coffee ☕ to refresh myself. If you like my Gradle 🐘 solution, would you mind to buy me a coffee? Thank you for your support! 🤗"
  custom: "<div style='display: flex; justify-content: center;'><a href='https://ko-fi.com/X7X56IIAQ' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi2.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a></div>"
# table: # uncomment to disable, default is true
  # sort: false
# comment: # uncomment to disable comment system
#   enable = false
lightgallery: true # uncomment if using the better image shortcode
code:
  maxShownLines: 50
seo:
  images: ["img/featured image.webp"] # same as featuredImage
---

TL;DR: Use the [gradle-buildconfig-plugin](https://github.com/gmazzo/gradle-buildconfig-plugin) or the [BuildKonfig](https://github.com/yshrsmz/BuildKonfig) plugin, in `buildSrc/build.gradle.kts`.

<!--more-->

{{< admonition type=quote title="Featured Image Source" open=true >}}
**Source**: [Medium](https://medium.com/@gopalsays108/android-gradle-version-catalog-by-gopal-cf459e90fb92)
{{< /admonition >}}

## Introduction

In this post, I am going to show you my workaround to a famous long-lasted Gradle issue about version catalogs. The issue is [gradle/gradle#15383](https://github.com/gradle/gradle/issues/15383). It is about accessing the version catalogs from precompiled script plugins.

## Understanding the issue

The issue [gradle/gradle#15383](https://github.com/gradle/gradle/issues/15383) is created by {{< person url="https://github.com/melix" name="Cédric Champeau" nick="melix" text="Member of Micronaut team and GraalVM team, contribute to several Micronaut's tools and the GraalVM Native Build Tools" picture="https://avatars.githubusercontent.com/u/316357?v=4" >}}, described as follows:

> In a similar way to [gradle/gradle#15382](https://github.com/gradle/gradle/issues/15382), we want to make the version catalogs accessible to precompiled script plugins. Naively, one might think that it's easier to do because precompiled script plugins are applied to the "main" build scripts, but this isn't necessarily the case:
>
> - first, precompiled script plugins can be published too, meaning that they are no different from regular plugins in practice
> - second, precompiled script plugins can be declared in included builds, not just buildSrc
>
> Therefore, the "version catalog" that a precompiled script plugin should see cannot be the catalog declared in the "main build". It cannot be, either, the catalog declared in the project which itself declares the precompiled script plugin (typically the settings file of the buildSrc project): in particular, the catalogs declared in buildSrc/settings.gradle are for the build logic of buildSrc itself, not for the "main" build.

This statement can be quite confusing for Gradle newbies. So, let's review some background knowledge about Gradle before we proceed.

### What is composite build?

Based on Gradle official documentation:

> a composite build is a build that includes other builds

In practice, a composite build is basically just the `includeBuild("relative/path/to/another/gradle/project")` in your `settings.gradle.kts` file. The `relative/path/to/another/gradle/project` itself is a valid, isolated, and self-contained gradle project that has its own `settings.gradle.kts` and `build.gradle.kts` files.

You can try adding the gradle wrapper to the `relative/path/to/another/gradle/project` project and import it into your IDEA. You will find that the IDEA will treat it as a normal gradle project just like your other gradle projects 😂.

### Precompiled script plugins as a composite build

Gradle official documentation mentioned two ways to [structure your multi-module project](https://docs.gradle.org/current/userguide/intro_multi_project_builds.html#sec:project_standard). You either use `buildSrc` or composite build, to share common build logic between subprojects in your multi-module project.

{{<image src="https://docs.gradle.org/current/userguide/img/multi-project-standards.png" caption="Structure of the multi-module project, from the Gradle official documentation" >}}

Here is the folder structure (copied from the official documentation):

```{title="Folder structure of the multi-module project"}
.
├── gradle/
├── gradlew
├── settings.gradle.kts
├── build-logic/ or buildSrc/
│   ├── settings.gradle.kts
│   └── conventions
│       ├── build.gradle.kts
│       └── src/main/kotlin/shared-build-conventions.gradle.kts
├── mobile-app/
│   └── build.gradle.kts
├── web-app/
│   └── build.gradle.kts
├── api/
│   └── build.gradle.kts
├── lib/
│   └── build.gradle.kts
└── documentation/
    └── build.gradle.kts
```

{{< admonition type=tip title="For composite build" open=true >}}

If using composite build, make sure to add the following code to your `settings.gradle.kts` in the project's root directory:

```kotlin {title="settings.gradle.kts"}
pluginManagement {
    includeBuild("./build-logic") // relative path to the build logic
}
```

{{< /admonition >}}

Both ways are more or less the same, because **`buildSrc` has been implicitly [treated as a composite build](https://docs.gradle.org/8.0/release-notes.html)** since Gradle 8.0.

Cool! So now your common build logic is a self-contained gradle project by itself. 😲

Now, let's forget about the main gradle project and just focus on your build logic:

```{title="Folder structure of the composite build"}
.
├── settings.gradle.kts
└── conventions
    ├── build.gradle.kts
    └── src/main/kotlin/shared-build-conventions.gradle.kts
```

Looks like a normal gradle project, right? 😂

So here comes the truth of precompiled script plugins.

### The truth of precompiled script plugins

Have you ever wondered why is the precompiled script plugin `shared-build-conventions.gradle.kts` placed in the `src/main/kotlin` folder? 🤔 Can it just stay in the first level in the build logic folder like `build-logic/shared-build-conventions.gradle.kts`?

Well, here I would like you to watch a video from {{<person url="https://onepiece.software/#jendrik" name="Jendrik Johannes" nick="jjohannes" text="A previous core member in Gradle team" picture="https://onepiece.software/img/jendrik.png" >}} titled [Understanding Gradle #25 – Using Java to configure builds](https://youtu.be/XnVZdMROVG8?list=PLWQK2ZdV4Yl2k2OmC_gsjDpdIBTN0qqkE&t=263). Basically, each `.gradle.kts` file (or `.gradle` file) is just an implementation of the [`Plugin`](https://docs.gradle.org/current/dsl/org.gradle.api.Project.html) interface, either as `Plugin<Project>` (for `build.gradle.kts`) or `Plugin<Settings>` (for `settings.gradle.kts`).

{{<image src="https://docs.gradle.org/current/userguide/img/author-gradle-4.png" caption="A `build.gradle.kts` script is just a piece of code configuring a `Project` instance" >}}

Therefore, the precompiled script plugin, sitting inside the `src/main/<jvm lanaguge>` folder, is just a normal source code that is technically no different from your business logic codes saved in the `src/main/<jvm language>` folder. Maybe the only difference is that your business codes start from the `main()` function, while the precompiled script plugin codes start from the `apply(Project project)` function in your `class MyPlugin implement Plugin<Project>` implementation.

### The true issue: Version Catalog, using it from `src/main/kotlin`? 🤔

Now, let's look back at the issue [gradle/gradle#15383](https://github.com/gradle/gradle/issues/15383):

"We want to make the version catalogs accessible to precompiled script plugins"

It is the last piece of the puzzle to centralize the version management into one single `libs.versions.toml`. However, if we translate this using the knowledge we reviewed above, it becomes:

"A file called `libs.versions.toml` is meant to be used in the `build.gradle.kts` file. Now we want to use it in the business code inside the `src/main/kotlin` folder."

Thing starts to sound wired, right? 🤔

That's why the issue gradle/gradle#15383 is rarely possible to be solved, because it is a design issue that breaks the separation of concerns principle.

## Existing workaround

Several intelligent people have proposed great workarounds to this issue. The most famous one is from {{<person url="https://github.com/Vampire" name="Björn Kautler" nick="Vampire" text="A core member in Gradle team" picture="https://avatars.githubusercontent.com/u/325196?v=4" >}}'s [comment](https://github.com/gradle/gradle/issues/15383#issuecomment-779893192) under the issue, where you `implementation()` a pretty internal Gradle file to get the version catalog. This workaround works but it is very hacky, not guaranteed to work in any Gradle project (at least it doesn't work for me 😕), not working for the `plugins {}` block as mentioned in [this comment](https://github.com/gradle/gradle/issues/15383#issuecomment-900569305), and the API the workaround relied on can change anytime in the future.

Are there other workarounds without hacks?

Fortunately, there is one for the `plugins {}` block, as mentioned in [this comment](https://github.com/gradle/gradle/issues/15383#issuecomment-1855984127). This method assumed that your `settings.gradle.kts` file in `buildSrc` or `build-logic` [imported the same version catalog](https://docs.gradle.org/current/userguide/platforms.html#sec:importing-catalog-from-file). This method also works for setting plugins, as I described in [this forum post](https://discuss.gradle.org/t/how-to-use-version-catalog-in-the-root-settings-gradle-kts-file/44603/5).

<!-- . If you have ever written a precompiled script plugin that applies other plugins, you know how painful is it to find the right coordinate of the dependency of the plugin from [Gradle Plugin Portal](https://plugins.gradle.org/), and add it into the `implementation()` inside the `build.gradle.kts` file. And that's right, your `build.gradle.kts` has direct access to the version catalog, as long as your `setting.gradle.kts` imported the `libs.versions.toml` that can be anywhere in your project. Therefore simply just add the plugin's dependency into the `[libraries]` section of the version catalog, and replace the string in `implementation()` with `libs.something`.  -->

{{<image src="img/Screenshot 2024-05-12 170857.png" caption="Screenshot from Jendrik Johannes (jjohannes)'s [video](https://www.youtube.com/watch?v=N95YI-szd78&list=PLWQK2ZdV4Yl2k2OmC_gsjDpdIBTN0qqkE&index=3) about writting your own precompiled script plugin. One of the step is to find the right coordinate of the plugin dependency. Fortunately, that coordinate can go into your version catalog." >}}

I also found another hack-free workaround for `dependencies {}` block, which I described in [this comment](https://github.com/gradle/gradle/issues/15383#issuecomment-1858465843). This method plays around the [Gradle platform](https://docs.gradle.org/current/userguide/platforms.html#sub:using-platform-to-control-transitive-deps) and the order of [different phases of Gradle](https://docs.gradle.org/current/userguide/build_lifecycle.html#sec:build_phases) in order to do the trick. However, that method is very annoying because adding/removing a dependency requires 3 modifications around your project.

Until now, without the hacky first method, the version catalog can only cover the `plugins {}` block and the `dependencies {}` block. In most cases, it is enough. But what if you want to use the version catalog in some plugins' extensions. For example, a precompiled script plugin that applies the [Micronaut Gradle Plugin](https://micronaut-projects.github.io/micronaut-gradle-plugin/latest/index.html), which requires setting the version of the Micronaut framework in the `micronaut {}` extension. 🤷‍♂️

{{<admonition type=Note title="Off topic: A fun fact about my feature request to the Micronaut Gradle Plugin" open=false >}}

One day, I was investigating the Micronaut framework. I realized that I couldn't apply any centralized version management solution mentioned in [Understanding Gradle #09 – Centralizing Dependency Versions](https://www.youtube.com/watch?v=8044F5gc1dE&list=PLWQK2ZdV4Yl2k2OmC_gsjDpdIBTN0qqkE&index=9) from {{<person name="Jendrik Johannes" nick="jjohannes" text="A previous core member in Gradle team" picture="https://onepiece.software/img/jendrik.png" >}}.

So I created a [feature request](https://github.com/micronaut-projects/micronaut-gradle-plugin/issues/681) to the Micronaut team. I even investigated into the source code of the plugin and pointed out the [codes](https://github.com/micronaut-projects/micronaut-gradle-plugin/blob/cc84332f5635e3da7c71e81460659f41fd36ae2b/minimal-plugin/src/main/java/io/micronaut/gradle/PluginsHelper.java#L48-L60) that prevent the use of the version catalog or the Gradle platform.

The same person, {{< person name="Cédric Champeau" nick="melix" text="Member of Micronaut team and GraalVM team, contribute to several Micronaut's tools and the GraalVM Native Build Tools" picture="https://avatars.githubusercontent.com/u/316357?v=4" >}}, who created the issue gradle/gradle#15383 responded. 😲

He quickly came up with [a PR](https://github.com/micronaut-projects/micronaut-gradle-plugin/pull/701). It adds a new option `importMicronautPlatform` to the Micronaut Gradle Plugin that can be set to `false` to allow you to achieve centralized version management with Gradle platform.

Today you can see that option is mentioned in the Micronaut Gradle Plugin [document](https://micronaut-projects.github.io/micronaut-gradle-plugin/latest/index.html#_micronaut_library_plugin).

{{< /admonition >}}

## Introducing the new beautiful workaround 🤩

All workarounds mentioned above are more or less doing one thing: "sending" the variables that are meant to be used in Gradle build files into the business code in the `src/main/kotlin` folder.

One day I was investigating the Compose Multiplatform framework and found two Gradle plugins: the [gradle-buildconfig-plugin](https://github.com/gmazzo/gradle-buildconfig-plugin) and the [BuildKonfig](https://github.com/yshrsmz/BuildKonfig) plugin.

Both plugins are typically used in Kotlin Multiplatform projects to generate a Kotlin file that contains configuration variables you defined inside the `build.gradle.kts` file.

For example, using the gradle-buildconfig-plugin, if you have the following code in your `build.gradle.kts`:

```kotlin {title="build.gradle.kts"}
plugins {
  // ...
  id("com.github.gmazzo.buildconfig") version <current version>
}

buildConfig {
  className("MyConfig")   // forces the class name. Defaults to 'BuildConfig'
  packageName("com.foo")  // forces the package. Defaults to '${project.group}'

  buildConfigField(String::class.java, 'APP_NAME', "my-project")
}
//...
```

You will get a Kotlin file like this:

```kotlin {title="com.foo.MyConfig.kt"}
package com.foo

object MyConfig {
  const val APP_NAME: String = "my-project"
}
```

Suddently, I realized that what if I apply this plugin to the `build.gradle.kts` inside the `buildSrc` or the `build-logic` folder? 😲

```toml {title="gradle/libs.versions.toml"}
[versions]
java = "21"
slf4j = "2.0.13"

[libraries]
slf4j-api = {module = "org.slf4j:slf4j-api", version.ref = "slf4j"}
```

```kotlin {title="build-logic/conventions/build.gradle.kts"}
plugins {
  // ...
  id("com.github.gmazzo.buildconfig") version <current version>
}

buildConfig {
  className("VersionCatalog")   // forces the class name. Defaults to 'BuildConfig'
  packageName("my.util")  // forces the package. Defaults to '${project.group}'

  buildConfigField(Int::class.java, "JAVA_VERSION", libs.versions.java.get().toInt())
  buildConfigField(String::class.java, "SLF4J_API", libs.dep.slf4j.get().toString())
}
```

Can my precompiled script plugin access `JAVA_VERSION` and `SLF4J_API` variables? 

Guess what? It actually works! 😱

```kotlin {title="build-logic/conventions/src/main/kotlin/shared-build-conventions.gradle.kts"}
import my.util.VersionCatalog

// other configs

java {
  toolchain {
    languageVersion.set(JavaLanguageVersion.of(VersionCatalog.JAVA_VERSION))
  }
}

dependencies {
  implementation(VersionCatalog.SLF4J_API)
}

// other configs
```

{{<figure src="img/ohhhhhhh.gif">}}

## Conclusion

The method that utilizes the gradle-buildconfig-plugin or the BuildKonfig plugin is a beautiful workaround for accessing Gradle Version Catalogs from precompiled script plugins. It is not too hacky, guaranteed to work in any Gradle project, and doesn't have the limitation where it is only accessible from the `plugins {}` block or the `dependencies {}` block. It is a great solution for centralizing version management in your Gradle project.

I hope this workaround can help you in your Gradle project. If you have any questions or suggestions, feel free to leave a comment below. 😊
