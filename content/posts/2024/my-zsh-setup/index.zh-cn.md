---
title: "分享我的Zsh设置：Oh My Zsh + Powerlevel10k + 插件 = ❤️"
# slug: "my-zsh-setup" # if :slug is in the permalinks configuration, use this to resolve URL conflict with other posts
date: 2024-03-12T19:37:30Z # if year month day in the permalinks configuration and other posts have the same date, modify this to resolve URL conflict with other posts
lastmod: 2024-03-12T19:37:30Z # no longer needed if enableGitInfo = true
draft: true # remember to change it back to false before opening the PR for publishing
authors: [CXwudi] # no quotes
featuredImage: "power10k screenshot.png"
description: ""
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
# sponsor: # uncomment to disable, default is false in config 
  # enable: false
# table: # uncomment to disable, default is true
  # sort: false
# comment: # uncomment to disable comment system
#   enable = false
# lightgallery: true # uncomment if using the better image shortcode
---

这是我第一次写技术性博客，来分享自己的知识和经验。今天，我想分享我的个人Zsh设置，包括Oh My Zsh + Powerlevel10k + 一些常用插件。这种设置让我的终端体验非常愉悦，我希望你能同我一样有着愉悦的终端体验。😊

<!--more-->

{{< admonition type=info title="注意" open=true >}}
此文章是从本站英文版原文通过GPT-4 Turbo翻译并适当修改而来，可能会出现语言不自然等Bug，请予以谅解。
{{< /admonition >}}

## 参考

本博客文章基于以下资源编写：

1. [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki)
2. [Powerlevel10k](https://github.com/romkatv/powerlevel10k#getting-started)

欢迎查看这些资源以获取更多详细信息。

## 前提条件

本指南适用于 Linux（包括 WSL2）、MacOS 和 Windows [Git Bash](https://git-scm.com/downloads)。

{{< admonition type=tip title="Windows Powershell 怎么样？" open=false >}}
查看 [oh-my-posh](https://ohmyposh.dev/) 以在 Powershell 中实现类似的设置。然而，本文不会涉及此内容。
{{< /admonition >}}

## 第1步：安装必要的字体

Powerlevel10k 最适合使用其专用字体 [_Meslo Nerd Font_](https://github.com/romkatv/powerlevel10k#manual-font-installation)。因此，你首先需要在你的操作系统上安装它。然后，对于你使用的每一个shell/终端程序（比如 VSCode、Intellij、Windows Terminal、iTerm2 等等），你需要配置它使用这些自定义字体。

我知道这是一项相当繁琐的工作。幸运的是，这里有来自Powerlevel10k官方GitHub仓库的[指南](https://github.com/romkatv/powerlevel10k#manual-font-installation)。该指南提供了如何在大多数流行的终端中配置终端以使用Meslo Nerd Font的说明。

## 第2步：安装必要的依赖项

Oh My Zsh 是一个基于Zsh之上的开源、社区驱动的框架。安装过程还需要在你的操作系统上安装其他依赖项。因此，请确保你已经安装了以下依赖项：

- `zsh`（Z shell）
- `git`（版本控制系统）
- `curl` 或 `wget`（用于下载安装脚本）

例如，在基于Debian的系统上，你可以使用以下命令安装它们：

```bash
sudo apt update
sudo apt install curl git zsh -y
```

对于Windows Git Bash，安装Zsh可能会有挑战。你可以查看Dominik Rys的[这篇文章](https://dominikrys.com/posts/zsh-in-git-bash-on-windows/#installing-zsh-in-git-bash)了解如何在Windows Git Bash中安装Zsh。

## 第3步：安装Oh My Zsh、Powerlevel10k和插件

此时，你应该已经安装了所有必要的依赖项。现在，运行以下命令来安装Oh My Zsh、Powerlevel10k和一些常用插件。

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/Pilaton/OhMyZsh-full-autoupdate ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ohmyzsh-full-autoupdate
```

上述脚本执行以下操作：

1. 安装Oh My Zsh，并取消询问用户是否将默认shell转换为Zsh的interactive shell。我们稍后将手动转换默认shell为Zsh。
2. 安装[Powerlevel10k](https://github.com/romkatv/powerlevel10k)主题。
3. 安装[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)插件。
   - 该插件为shell提供语法高亮。这样，你可以在按下回车键之前意识到是否拼错了命令。
4. 安装[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)插件。
   - 该插件根据history和completion来补全你的命令，这可以大大节省你在做重复任务和命令上的时间。
5. 安装[OhMyZsh-full-autoupdate](https://github.com/Pilaton/OhMyZsh-full-autoupdate)插件。
   - 由于所有内容都是使用git安装的，因此保持它们的更新至关重要。该插件通过在后台运行`git pull`来自动更新Powerlevel10k和Oh My Zsh插件。更新频率取决于Oh My Zsh的设置，默认情况下应该是每13天一次。

## 第4步：配置`.zshrc`以使用Powerlevel10k和插件

就像Bash使用`.bashrc`一样，Zsh使用`.zshrc`作为配置文件。

默认情况下，Oh My Zsh将创建一个带有默认主题和单个插件`git`的`.zshrc`文件。要启用我们刚刚安装的Powerlevel10k和插件，我们需要修改`.zshrc`文件。

用你喜欢的文本编辑器（如`nano`）打开它，并更改以下：

1. 更改主题，从`ZSH_THEME="robbyrussell"`更改为`ZSH_THEME="powerlevel10k/powerlevel10k"`。
2. 在`plugins`数组中添加更多插件，从`plugins=(git)`更改为：
    ```bash
    plugins=(git aliases common-aliases zsh-syntax-highlighting zsh-autosuggestions ohmyzsh-full-autoupdate)
    ```

以上可以通过运行两个`sed`命令来实现：

```bash
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(git aliases common-aliases zsh-syntax-highlighting zsh-autosuggestions ohmyzsh-full-autoupdate)/' ~/.zshrc
```

## 第5步：将`.bashrc`迁移到`.zshrc`，将`.profile`迁移到`.zprofile`

如果你正在设置新系统，请跳过此步骤。

如果你正在将现有系统从Bash迁移到Zsh，你可能需要花些时间将你的`.bashrc`和`.profile`分别迁移到`.zshrc`和`.zprofile`。

不幸的是，没有办法自动化迁移过程。我也强烈不建议你在`.bashrc`或`.profile`文件的末尾执行Zsh，因为它可能会使其他脚本、应用程序或IDE出bug。

然而，在迁移过程中一些值得考虑的通用事项包括：

- 由第三方包管理器（如Homebrew、SDKMan等）添加到你的`.bashrc`或`.profile`的脚本。
- 自定义环境变量。
- 自定义`PATH`。
- 自定义alias。
  - 可以考虑替换使用Oh My Zsh中已有的插件。查看[`common-aliases`](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/common-aliases)插件以及[官方文档](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins)中以获得更多信息。
  - 例如，如果你使用Docker，考虑将[`docker`](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker)和`docker-compose`添加到`.zshrc`的`plugins`数组中。

## 第6步：将Zsh设置为默认Shell

最后，通过运行以下命令将Zsh设置为默认shell：

```bash
chsh -s $(which zsh)
```

对于Windows Git Bash，据我所知，没有官方方法将另一个shell设置为默认shell。然而，你可以在每次打开终端时手动运行`zsh`。或者将此脚本追加到你的`.bashrc`文件末尾，以便在你打开终端时自动运行Zsh（是的，这与我在第5步中所说的相反，但这是我们目前能做的最好的 😕）：

```bash
# 最后，切换到zsh
if [[ -t 1 && -x /usr/bin/zsh ]]; then
    export SHELL=$(which zsh)
    if [[ -o login ]]
    then
        exec zsh -l
    else
        exec zsh
    fi
fi
```

> 如果你有更好的解决方案将Zsh设置为Windows Git Bash的默认shell，欢迎在下方评论区留言。

## 第7步：运行Powerlevel10k配置向导

在将Zsh设置为默认shell之后，启动新的终端会话将立即带你进入Powerlevel10k配置向导。你也可以随时运行`p10k configure`再次启动向导。向导将引导你根据你自己的喜好配置Powerlevel10k。

{{< figure src="power10k-configuration-wizard.gif" caption="Powerlevel10k配置向导的屏幕录像（来自官方GitHub仓库）">}}

完成向导可能会比较耗时。所以在这里，我准备了一段snippet，你可以使用它来快速配置Powerlevel10k，使其与上面GIF中显示的样式相似。只需在你刚开始运行`p10k configure`时复制并粘贴它即可：

```bash
y
y
y
y
3
1
2
1
1
1
2
2
3 # 如果你想使用本博文封面中显示的样式，请将此项更改为1
2
2
2
1
y
1
y
```

## 结论

就是这样！你已经成功地设置了Oh My Zsh与Powerlevel10k和一些常用插件。现在你可以享受更高效、更愉快的终端体验了。😁

有任何问题或建议？欢迎在下方评论区留言。