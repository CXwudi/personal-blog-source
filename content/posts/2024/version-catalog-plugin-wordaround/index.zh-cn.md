---
title: "从预编译脚本插件访问Gradle版本目录的漂亮解决方案"
# slug: "" # 如果在永久链接配置中有:slug，使用这个来解决与其他帖子的URL冲突
date: 2024-05-12T14:52:55Z # 如果永久链接配置中有年月日，并且其他帖子有相同的日期，修改这个来解决URL冲突
lastmod: 2024-05-12T14:52:55Z # 如果启用了enableGitInfo，则不再需要
draft: false # 发布前记得将其改为false
authors: [CXwudi] # 没有引号
featuredImage: "img/featured image.webp"
description: "使用gradle-buildconfig-plugin或BuildKonfig插件从预编译脚本插件访问Gradle版本目录"
# license: '<a rel="license external nofollow noopener noreffer" href="https://creativecommons.org/licenses/by/4.0/" target="_blank">CC BY 4.0</a>'

# 所有三个都需要引号
tags: [devops]
categories: [tech]
series: []
series_weight: 

# 你可以从[params.page]复制任何配置到这里来覆盖全局默认

# outdatedArticleReminder: # 取消注释以启用，默认在配置中为false
  # enable: true
  # reminder: 180
  # warning: 365
sponsor:
  enable: true
  bio: "写完这篇文章后，我感到非常疲惫 😫。我需要一杯咖啡 ☕ 来提神。如果你喜欢我的Gradle 🐘 解决方案，你介意请我喝一杯咖啡吗？感谢你的支持！🤗"
  custom: "<div style='display: flex; justify-content: center;'><a href='https://ko-fi.com/X7X56IIAQ' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi2.png?v=3' border='0' alt='在ko-fi.com给我买咖啡' /></a></div>"
# table: # 取消注释以禁用，默认为true
  # sort: false
# comment: # 取消注释以禁用评论系统
#   enable = false
lightgallery: true # 如果使用更好的图片shortcode则取消注释
code:
  maxShownLines: 50
seo:
  images: ["img/featured image.webp"] # 与featuredImage相同
---

太长不看：在 `buildSrc/build.gradle.kts` 中应用 [gradle-buildconfig-plugin](https://github.com/gmazzo/gradle-buildconfig-plugin) 或 [BuildKonfig](https://github.com/yshrsmz/BuildKonfig) 插件。

<!--more-->
{{< admonition type=quote title="封面来源" open=true >}}
**来源**: [Medium](https://medium.com/@gopalsays108/android-gradle-version-catalog-by-gopal-cf459e90fb92)
{{< /admonition >}}
{{< admonition type=info title="注意" open=true >}}
此文章是从本站英文版原文通过GPT-4 Turbo翻译并适当修改而来，可能会出现语言不自然等Bug，请予以谅解。
{{< /admonition >}}

## 简介

长期以来，Gradle社区一直面临一个几乎无法解决的问题[gradle/gradle#15383](https://github.com/gradle/gradle/issues/15383)，这导致了极大的挫败感。问题涉及到如何从precompiled script plugin访问version catalog。虽然存在许多workaround，但今天我想向您展示我最近找到的一种workaround。

让我们开始吧。

## 理解问题

问题[gradle/gradle#15383](https://github.com/gradle/gradle/issues/15383)由{{< person url="https://github.com/melix" name="Cédric Champeau" nick="melix" text="Micronaut团队和GraalVM团队成员，为多个Micronaut工具和GraalVM Native Build Tools做出了贡献" picture="https://avatars.githubusercontent.com/u/316357?v=4" >}}提出，内容如下：

> In a similar way to [gradle/gradle#15382](https://github.com/gradle/gradle/issues/15382), we want to make the version catalogs accessible to precompiled script plugins. Naively, one might think that it's easier to do because precompiled script plugins are applied to the "main" build scripts, but this isn't necessarily the case:
>
> - First, precompiled script plugins can be published too, meaning that they are no different from regular plugins in practice
> - Second, precompiled script plugins can be declared in included builds, not just buildSrc
>
> Therefore, the "version catalog" that a precompiled script plugin should see cannot be the catalog declared in the "main build". It cannot be, either, the catalog declared in the project which itself declares the precompiled script plugin (typically the settings file of the buildSrc project): in particular, the catalogs declared in buildSrc/settings.gradle are for the build logic of buildSrc itself, not for the "main" build.

{{< admonition type=note title="翻译文本" open=false >}}

类似于[gradle/gradle#15382](https://github.com/gradle/gradle/issues/15382)，我们希望使precompiled script plugin能够访问version catalog。天真地认为这很容易，因为precompiled script plugin是应用于“主”构建脚本的，但实际情况并非如此：

- 首先，precompiled script plugin也可以被发布，这意味着它们在实践中与常规插件没有区别
- 其次，precompiled script plugin可以在包含的构建中声明，而不仅仅是buildSrc

因此，precompiled script plugin应该看到的“version catalog”不能是在“主构建”中声明的目录。它也不能是声明precompiled script plugin的项目（通常是buildSrc项目的设置文件）中声明的目录：特别是，在buildSrc/settings.gradle中声明的目录是为buildSrc自身的构建逻辑而非“主”构建。

{{< /admonition >}}

简而言之，precompiled script plugin无法访问version catalog，而且解决这个问题相当困难。但为什么呢？为了更好地理解这个问题，让我们回顾一下Gradle中的一些概念。

### 什么是composite build？

Gradle官方文档说：

> A composite build is a build that includes other builds.

翻译过来就是：

> composite build是包含其他构建的构建。

基本上，这就是你在`settings.gradle.kts`文件中的`includeBuild("relative/path/to/another/gradle/project")`语句。包含的构建本身是一个有效的、独立的、自成体系的Gradle项目，它也有自己的`settings.gradle.kts`和/或`build.gradle.kts`文件。

你可以尝试在`relative/path/to/another/gradle/project`中添加Gradle wrapper，并在你的IDEA中打开该文件夹。然后你的IDEA就会将其视为一个普通的Gradle项目，就像你平常的Java Gradle项目😂。

### precompiled script plugin作为composite build

Gradle官方文档推荐两种[构建多模块项目的结构](https://docs.gradle.org/current/userguide/intro_multi_project_builds.html#sec:project_standard)方式。要么使用`buildSrc`，要么使用composite build将常见的构建逻辑提取到一个构建项目中，供你的多模块项目中的子项目使用。

{{<image src="https://docs.gradle.org/current/userguide/img/multi-project-standards.png" caption="多模块项目的结构，来自Gradle官方文档" >}}

这是文件夹结构：

```
.
├── gradle/
├── gradlew
├── settings.gradle.kts
├── build-logic/ 或 buildSrc/
│   ├── settings.gradle.kts
│   └── conventions
│       ├── build.gradle.kts
│       └── src/main/kotlin/shared-build-conventions.gradle.kts
├── sub-project1/
│   └── build.gradle.kts
├── sub-project2/
│   └── build.gradle.kts
└── lib/
    └── build.gradle.kts
```

自Gradle 8.0起，**`buildSrc`已开始[表现得更像一个composite build](https://docs.gradle.org/8.0/release-notes.html)**。现在这两种方式基本上是相同的。

很好！😄 等于说提取出来的常见构建逻辑本身就是一个独立的Gradle项目。

事实上，如果你仔细看看构建项目的文件夹结构。

```
.
├── settings.gradle.kts
└── conventions
    ├── build.gradle.kts
    └── src/main/kotlin/shared-build-conventions.gradle.kts
```

它看起来就像一个普通的Gradle项目，对吧？

所以，接下来就是precompiled script plugin的真相了。

### precompiled script plugin的真相

你是否曾经好奇为什么precompiled script plugin会被放在`src/main/kotlin`文件夹中？🤔 就像上面的`shared-build-conventions.gradle.kts`示例。它能否就留在构建项目的第一层，比如`build-logic/shared-build-conventions.gradle.kts`？

这里，我想邀请你观看{{<person url="https://onepiece.software/#jendrik" name="Jendrik Johannes" nick="jjohannes" text="Gradle团队的前核心成员" picture="https://onepiece.software/img/jendrik.png" >}}的一个视频，标题为[Understanding Gradle #25 – Using Java to configure builds](https://youtu.be/XnVZdMROVG8?list=PLWQK2ZdV4Yl2k2OmC_gsjDpdIBTN0qqkE&t=263)。基本上，每个Gradle脚本都是[`Plugin`](https://docs.gradle.org/current/dsl/org.gradle.api.Project.html)接口的一个实现。构建脚本`build.gradle.kts`对应`Plugin<Project>`，设置脚本`settings.gradle.kts`对应`Plugin<Settings>`。

{{<image src="https://docs.gradle.org/current/userguide/img/author-gradle-4.png" caption="构建脚本只是配置`Project`实例的一段代码，precompiled script plugin也是如此" >}}

因此，放在`src/main/<jvm language>`文件夹中的precompiled script plugin也是业务逻辑代码，但这里的业务逻辑是你主项目的构建逻辑。这种代码通常从你的`class MyPlugin implements Plugin<Project>`实现中的`apply(Project project)`方法开始。

### 在`src/main/kotlin`中使用version catalog？🤔

现在，让我们回顾一下[gradle/gradle#15383](https://github.com/gradle/gradle/issues/15383)中的声明：

> We want to make the version catalogs accessible to precompiled script plugins

翻译过来:

> 我们希望使version catalog对precompiled script plugin可见

利用我们上面回顾的知识来翻译这句话，它就变成了：

“一个名为`libs.versions.toml`的文件本意是用在`build.gradle.kts`文件中。现在我们想在`src/main/kotlin`文件夹中的业务代码中使用它。”

听起来很奇怪，不是吗？🤔

这就是为什么这个问题很难解决的原因，因为这是一个设计问题，违反了关注点分离原则。

## 现有的workaround

一些聪明的人提出了几个绝妙的workaround。最著名的一个来自{{<person url="https://github.com/Vampire" name="Björn Kautler" nick="Vampire" text="Gradle团队的核心成员" picture="https://avatars.githubusercontent.com/u/325196?v=4" >}}的[评论](https://github.com/gradle/gradle/issues/15383#issuecomment-779893192)，其中你需要添加一个隐秘的Gradle内部文件到`dependencies {}`块中。这个方法虽然有效，但非常hacky，不能保证在任何Gradle项目中都有效（至少我没弄成功过 😕），[在`plugins {}`块中不起作用](https://github.com/gradle/gradle/issues/15383#issuecomment-900569305)，而且这个workaround依赖于一个可能随时变更的Gradle内部API。

还有其他不需要hack的workaround吗？

幸运的是，有一个针对`plugins {}`块的workaround，如[此评论](https://github.com/gradle/gradle/issues/15383#issuecomment-1855984127)中提到的。由于将外部插件应用到precompiled script plugin需要将外部插件的相应依赖添加到`build.gradle.kts`文件中，你可以将哪个依赖放进version catalog中。这种方法假设构建项目中的`settings.gradle.kts`文件[导入了与主项目中使用的相同的version catalog](https://docs.gradle.org/current/userguide/platforms.html#sec:importing-catalog-from-file)。我还发现这种方法适用于设置插件，正如我在[此论坛帖子](https://discuss.gradle.org/t/how-to-use-version-catalog-in-the-root-settings-gradle-kts-file/44603/5)中描述的那样。

{{<image src="img/Screenshot 2024-05-12 170857.png" caption="Jendrik Johannes (jjohannes)的[视频](https://www.youtube.com/watch?v=N95YI-szd78&list=PLWQK2ZdV4Yl2k2OmC_gsjDpdIBTN0qqkE&index=3)截图，介绍了编写你自己的precompiled script plugin的步骤之一，就是找到插件依赖的正确coordinate。幸运的是，这个coordinate可以进入你的version catalog。" >}}

我还找到了一个不需要hack的`dependencies {}`块的workaround，并在[此评论](https://github.com/gradle/gradle/issues/15383#issuecomment-1858465843)中进行了描述。这种workaround利用了[Gradle platform](https://docs.gradle.org/current/userguide/platforms.html#sub:using-platform-to-control-transitive-deps)和[Gradle的构建阶段](https://docs.gradle.org/current/userguide/build_lifecycle.html#sec:build_phases)来实现目的。然而，这种方法非常麻烦，因为添加/移除依赖需要在你的项目中进行三处修改。

总的来说，非hacky的workaround可以覆盖`plugins {}`块和`dependencies {}`块。在大多数情况下，这已经足够。但是对于[extensions](https://docs.gradle.org/current/userguide/implementing_gradle_plugins_precompiled.html#sec:getting_input_from_the_build)怎么办呢？例如，如果precompiled script plugin应用了[Micronaut Gradle插件](https://micronaut-projects.github.io/micronaut-gradle-plugin/latest/index.html)，如何使用version catalog在`micronaut {}`扩展中设置Micronaut框架的版本呢？🤷‍♂️

{{<admonition type=Note title="题外话：关于我对Micronaut Gradle插件的功能请求的有趣事件" open=false >}}

有一天，我在研究Micronaut框架时，意识到我无法应用{{<person name="Jendrik Johannes" nick="jjohannes" text="Gradle团队的前核心成员" picture="https://onepiece.software/img/jendrik.png" >}}在[Understanding Gradle #09 – Centralizing Dependency Versions](https://www.youtube.com/watch?v=8044F5gc1dE&list=PLWQK2ZdV4Yl2k2OmC_gsjDpdIBTN0qqkE&index=9)中提到的任何集中版本管理解决方案。

所以我向Micronaut团队提出了一个[功能请求](https://github.com/micronaut-projects/micronaut-gradle-plugin/issues/681)。我甚至深入研究了插件的源代码，并指出了阻止使用version catalog或Gradle platform的[代码](https://github.com/micronaut-projects/micronaut-gradle-plugin/blob/cc84332f5635e3da7c71e81460659f41fd36ae2b/minimal-plugin/src/main/java/io/micronaut/gradle/PluginsHelper.java#L48-L60)。

创建了gradle/gradle#15383问题的那个人，{{< person name="Cédric Champeau" nick="melix" text="Micronaut团队和GraalVM团队成员，为多个Micronaut工具和GraalVM Native Build Tools做出了贡献" picture="https://avatars.githubusercontent.com/u/316357?v=4" >}}回应了我。😲

他很快提出了[一个PR](https://github.com/micronaut-projects/micronaut-gradle-plugin/pull/701)，在Micronaut Gradle插件中增加了一个新选项`importMicronautPlatform`，可以设置为`false`以允许你使用Gradle platform实现集中版本管理。一旦我能够使用Gradle platform，我就能够使用我上面提到的workaround来使用version catalog。

今天，你可以在Micronaut Gradle插件的[文档](https://micronaut-projects.github.io/micronaut-gradle-plugin/latest/index.html#_micronaut_library_plugin)中看到这个选项。

{{< /admonition >}}

## 现在开始介绍全新漂亮的workaround 🤩

上面提到的所有workaround或多或少都在做一件事：“发送”原本应该用在Gradle构建脚本中的变量到`src/main/kotlin`文件夹中的业务代码里。

有一天，我无意中发现了两个Gradle插件：[gradle-buildconfig-plugin](https://github.com/gmazzo/gradle-buildconfig-plugin)和[BuildKonfig](https://github.com/yshrsmz/BuildKonfig)插件。

这两个插件通常用于Kotlin跨平台项目（通常是跨平台Compose应用），用来生成一个包含你在`build.gradle.kts`脚本中定义的配置变量的Kotlin文件。

例如，如果你有：

```kotlin {title="build.gradle.kts"}
plugins {
  // ...
  id("com.github.gmazzo.buildconfig") version <current version>
}

buildConfig {
  className("MyConfig")   // 强制类名。默认为'BuildConfig'
  packageName("com.foo")  // 强制包名。默认为'${project.group}'

  buildConfigField(String::class.java, 'APP_NAME', "my-project")
}
//...
```

你会得到：

```kotlin {title="com.foo.MyConfig.kt"}
package com.foo

object MyConfig {
  const val APP_NAME: String = "my-project"
}
```

突然间，我意识到如果我将这个插件应用到构建项目中的`build.gradle.kts`会怎样？😲

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
  className("VersionCatalog")   // 强制类名。默认为'BuildConfig'
  packageName("my.util")  // 强制包名。默认为'${project.group}'

  buildConfigField(Int::class.java, "JAVA_VERSION", libs.versions.java.get().toInt())
  buildConfigField(String::class.java, "SLF4J_API", libs.dep.slf4j.get().toString())
}
```

那么，我的precompiled script plugin能访问`JAVA_VERSION`和`SLF4J_API`变量吗？

你擦怎么着？它居然真的有效！😱

```kotlin {title="build-logic/conventions/src/main/kotlin/shared-build-conventions.gradle.kts"}
import my.util.VersionCatalog

// 其他配置

java {
  toolchain {
    languageVersion.set(JavaLanguageVersion.of(VersionCatalog.JAVA_VERSION))
  }
}

dependencies {
  implementation(VersionCatalog.SLF4J_API)
}

// 其他配置
```

{{<figure src="img/ohhhhhhh.gif">}}

## 结论

利用gradle-buildconfig-plugin或BuildKonfig插件的方法是从precompiled script plugin访问Gradle的version catalog是一个漂亮的workaround。它不是太hacky，能确保在任何Gradle项目中都行得通，而且没有仅在`plugins {}`块或`dependencies {}`块可访问的限制。这是一个在你的Gradle项目中集中版本管理的绝佳解决方案。

我希望这个workaround能帮助到你的Gradle项目。如果你有任何问题或建议，欢迎在下面留言。😊
