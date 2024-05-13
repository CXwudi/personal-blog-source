---
title: "Gradle Version Catalog Issue"
slug: "gradle-version-catalog-issue" # if :slug is in the permalinks configuration, use this to resolve URL conflict with other posts
date: 2024-05-12T14:53:10Z # if year month day in the permalinks configuration and other posts have the same date, modify this to resolve URL conflict with other posts 
lastmod: 2024-05-12T14:53:10Z # no longer needed if enableGitInfo = true
draft: true # remember to change it back to false before opening the PR for publishing
authors: [] # no quotes
featuredImage: ""
description: ""
# license: '<a rel="license external nofollow noopener noreffer" href="https://creativecommons.org/licenses/by/4.0/" target="_blank">CC BY 4.0</a>'

# need quotes for all three
tags: []
categories: []
series: []
series_weight: 

# you can copy any config from [params.page] to here to override global default

# outdatedArticleReminder: # uncomment to enable, default is false in config 
  # enable: true
  # reminder: 180
  # warning: 365
# sponsor: # uncomment to disable, default is false in config 
  # enable: false
# table: # uncomment to disable, default is true
  # sort: false
# comment: # uncomment to disable comment system
#   enable = false
# lightgallery: true # uncomment if using the better image shortcode
seo:
  images: [] # same as featuredImage
---

太长不看：在 `buildSrc/build.gradle.kts` 中应用 [gradle-buildconfig-plugin](https://github.com/gmazzo/gradle-buildconfig-plugin) 或 [BuildKonfig](https://github.com/yshrsmz/BuildKonfig) 插件。

<!--more-->
{{< admonition type=quote title="封面来源" open=true >}}
**来源**: [Medium](https://medium.com/@gopalsays108/android-gradle-version-catalog-by-gopal-cf459e90fb92)
{{< /admonition >}}
{{< admonition type=info title="注意" open=true >}}
此文章是从本站英文版原文通过[什么工具]翻译并适当修改而来，可能会出现语言不自然等Bug，请予以谅解。
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
