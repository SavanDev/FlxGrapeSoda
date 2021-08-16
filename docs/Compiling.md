# Compilation instructions

## Haxe/HaxeFlixel stuff

For compile the game, __first__... you need:

- Install [Haxe](https://haxe.org/download/).
- Install [HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/).
- Install [Git](https://git-scm.com/) (only if you compile for desktop).

Later, you need install this __additional libraries__ (depending your target platform):

### For all platforms (Desktop/Web/Android)
```console
haxelib install flixel-addons
```

### For desktop (Windows/Linux/macOS)
```console
haxelib install flixel-ui
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
```

## Build executable

### Hashlink

- Download [Hashlink](https://github.com/HaxeFoundation/hashlink/releases).
- Decompress the zip (in a fixed folder).
- Run "**lime setup hl**" and follow the steps.
- In the root game folder, now run "lime test hl".

And that's all.

### Windows

In order to compile the game on Windows, you need to download [Visual Studio Community 2019](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community&rel=16) (or [Build Tools](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=BuildTools&rel=16) if you don't want the IDE).

Instead of installing any workload, go to the individual components and select the following options:

**For x64 systems**
- MSVC v142 - VS 2019 C++ x64/x86 build tools
- Windows 10 SDK (Latest)

**For x86 systems**
- MSVC v140 - VS 2015 C++ Build Tools (v14.00)
- Windows 10 SDK (Latest)

Later, simply use "**lime test windows**" in the root folder.

### Linux

#### Ubuntu/Debian distros

```console
$ sudo apt-get install g++ gcc-multilib g++-multilib    # Manual
$ lime setup linux                                      # Self-configured
```

#### Arch Linux

On Arch Linux, you first need to enable the [multilib](https://wiki.archlinux.org/title/Official_repositories#Enabling_multilib) repository for the process to finish correctly.

Then, running "**lime setup linux**" should be enough (needs **sudo**).

> In both, to finish simply use "**lime test linux**" in the root folder.

## Docker (Not recommend yet)

The Dockerfile was made to build Linux and Android more easily. **ONLY WORK ON LINUX**

```console
# docker build -t grapesoda .
# docker run -v "$PWD":/opt/FlxGrapeSoda grapesoda          # Compile for Android
# docker run -v "$PWD":/opt/FlxGrapeSoda grapesoda linux    # Compile for Linux
```