---
title: "{{ replace .Name "-" " " | title }}"
slug: "" # if :slug is in the permalinks configuration, use this to resolve URL conflict with other posts
date: {{ .Date }} # if year month day in the permalinks configuration and other posts have the same date, modify this to resolve URL conflict with other posts 
lastmod: {{ .Date }} # no longer needed if enableGitInfo = true
draft: true # remember to change it back to false before opening the PR for publishing
authors: [] # no quotes
description: ""
featuredImage: ""
# license: '<a rel="license external nofollow noopener noreffer" href="https://creativecommons.org/licenses/by/4.0/" target="_blank">CC BY 4.0</a>'

# need quotes for all three
tags: []
categories: []
series: []
series_weight: 

# outdatedArticleReminder: # uncomment to enable, default is false in config 
  # enable: true
  # reminder: 180
  # warning: 365
# sponsor: # uncomment to disable, default is false in config 
  # enable: false
---

abstract

<!--more-->
{{< admonition type=quote title="Featured Image Source/封面来源" open=false >}}
**Artist/画师**: [name](link to artist's pixiv / twitter / blog) <!--just to insert a double space behind-->  
**Source/来源**: [Image source platform](link to image)
{{< /admonition >}}
{{< admonition type=info title="注意/Attension" open=true >}}
此文章由英文版原文通过百度/DeepL翻译并做适当修改而来，可能会出现语言不自然等bug，望请谅解
This content is translated from the original Chinses version of the post through Baidu/DeepL translation and modified appropriately.
Please forgive me if there are some bugs such as unfluent English sentences.
{{< /admonition >}}

content
