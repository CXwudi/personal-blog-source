---
title: "Sharing my Zsh setup: Oh My Zsh + Powerlevel10k + plugins = ❤️"
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

Whether you're a developer, system administrator, or just an enthusiast of the terminal, enhancing your command-line interface can significantly boost your productivity and make terminal tasks more enjoyable.

Today, I'd like to share my own setup of Oh My Zsh + Powerlevel10k + some common plugins that increase my productivity. Just take 10 minutes to read through this post, and you could have the same setup as mine. 😁

<!--more-->

## Reference

This blog post is written based on the following resources:

1. [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki)
2. [Powerlevel10k](https://github.com/romkatv/powerlevel10k#getting-started)

Feel free to check them out for more detailed information.

## Prerequisites

This guide works well for Linux (including WSL2), MacOS, and Windows [git-bash](https://git-scm.com/downloads).

{{< admonition type=tip title="What about Windows Powershell?" open=false >}}
Check out [oh-my-posh](https://ohmyposh.dev/) for a similar setup in Powershell. However, this post won't cover it.
{{< /admonition >}}

## Step 1: Install Necessary Fonts

Powerlevel10k works best with its own font called [_Meslo Nerd Font_](https://github.com/romkatv/powerlevel10k#manual-font-installation). Therefore, you need to install it on your OS first. Then, for each shell/terminal program you use (VSCode, Intellij, Windows Terminal, iTerm2, to name a few...), you need to configure it to use these custom fonts.

Fortunately, the [guidance](https://github.com/romkatv/powerlevel10k#manual-font-installation) from the powerlevel10k official GitHub repository covers the instructions for most popular terminals and shells on how to configure your terminal to use the Meslo Nerd Font.

## Step 2: Install Necessary Dependencies

Oh My Zsh is an open-source, community-driven framework built on top of Zsh. The installation also requires other dependencies to be installed on your OS. So, make sure you have the following installed:

- `zsh` (Z shell)
- `git` (version control system)
- `curl` or `wget` (to download the installation script)

For example, on a Debian-based system, you can install them with the following command:

```bash
sudo apt update
sudo apt install curl git zsh -y
```

For Windows Git Bash, installing Zsh can be challenging. You can check out [this post](https://dominikrys.com/posts/zsh-in-git-bash-on-windows/#installing-zsh-in-git-bash) by Dominik Rys for how to install Zsh in Windows Git Bash.

## Step 3: Install Oh My Zsh, Powerlevel10k, and Plugins

At this point, you should have all the necessary dependencies installed. Now, run the following to install Oh My Zsh, Powerlevel10k, and some common plugins.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/Pilaton/OhMyZsh-full-autoupdate ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ohmyzsh-full-autoupdate
```

The above script does the following:

1. Install Oh My Zsh without triggering the interactive shell that asks the user to transfer the default shell to Zsh or not. We will transfer the default shell to Zsh manually later.
2. Install the [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme.
3. Install the [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) plugin.
   - This plugin provides syntax highlighting for the shell, so you will know if you have typed a command incorrectly before pressing enter.
4. Install the [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) plugin.
   - This plugin suggests commands as you type based on history and completions, which can dramatically save your time on repetitive tasks and commands.
5. Install the [OhMyZsh-full-autoupdate](https://github.com/Pilaton/OhMyZsh-full-autoupdate) plugin.
   - Since everything is installed using git, it is crucial to keep them up-to-date. This plugin will automatically update Powerlevel10k and Oh My Zsh plugins by running `git pull` in the background. The update frequency depends on the Oh My Zsh settings, by default, it should be every 13 days.

## Step 4: Configuring `.zshrc` to use Powerlevel10k and Plugins

Like Bash uses `.bashrc`, Zsh uses `.zshrc` as the configuration file.

By default, Oh My Zsh will create a `.zshrc` file with a default theme and a single plugin `git`. To enable Powerlevel10k and the plugins we just installed, we need to modify the `.zshrc` file.

Open it with your favorite text editor like `nano` and change the following lines:

1. Change the theme from `ZSH_THEME="robbyrussell"` to `ZSH_THEME="powerlevel10k/powerlevel10k"`.
2. Add more plugins to the `plugins` array, from `plugins=(git)` to:
    ```bash
    plugins=(git aliases common-aliases zsh-syntax-highlighting zsh-autosuggestions ohmyzsh-full-autoupdate)
    ```

The above can be achieved by running two `sed` commands:

```bash
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(git aliases common-aliases zsh-syntax-highlighting zsh-autosuggestions ohmyzsh-full-autoupdate)/' ~/.zshrc
```

## Step 5: Migrate `.bashrc` to `.zshrc`, and `.profile` to `.zprofile`

Skip this step if you are setting up a new system.

If you are migrating from Bash to Zsh on your existing system, you should take some time to migrate your `.bashrc` and `.profile` to `.zshrc` and `.zprofile`, respectively.

Unfortunately, there is no automatic way to do the migration. I also strongly discourage you from executing Zsh at the end of your `.bashrc` or `.profile` file, as it can cause problems for other scripts, applications, or IDEs.

However, some general things to consider for migration are:

- Scripts that third-party package managers like Homebrew, SDKMan, etc. have added to your `.bashrc` or `.profile`.
- Custom environment variables.
- Custom paths.
- Custom aliases.
  - Consider migrating to existing plugins in Oh My Zsh. Check out the [`common-aliases`](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/common-aliases) plugin and more in the [official documentation](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins).
  - For example, if you use Docker, consider adding the [`docker`](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker) and `docker-compose` aliases to the `plugins` array in `.zshrc`.

## Step 6: Set Zsh as the Default Shell

Finally, set Zsh as the default shell by running the following command:

```bash
chsh -s $(which zsh)
```

For Windows Git Bash, as far as I know, there is no official way to set another shell as the default shell. However, you can run `zsh` manually every time you open the terminal. Or append this script to the end of your `.bashrc` file to automatically run Zsh when you open the terminal (Yeah, it goes against what I said in Step 5, but it's the best we can do for now 😕):

```bash
# At the end, switch to zsh
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

## Step 7: Bootstrapping Powerlevel10k

After you have set Zsh as the default shell, starting a new terminal session will immediately bring you to the Powerlevel10k configuration wizard. You can also run `p10k configure` at any time to run the wizard again. The wizard will guide you through the process of configuring Powerlevel10k to your liking.

{{< figure src="power10k-configuration-wizard.gif" caption="Screen recording of the Powerlevel10k Configuration Wizard (from the official GitHub repo)" alt="Image Alt Text" >}}

Going through the wizard can be time-consuming. So here, I have prepared a snippet of answers that you can use to quickly configure Powerlevel10k. Just copy and paste it when you have just started the `p10k configure` wizard:

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
3 # change this to 1 if you want to use the style shown in the featured image of this post
2
2
2
1
y
1
y
```

## Conclusion

That's it! You have successfully set up Oh My Zsh with Powerlevel10k and some common plugins. Now you can enjoy a more productive and enjoyable terminal experience. 😁