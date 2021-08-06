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
- In the root game folder, now run "lime test hl -debug".

And that's all.

### Windows/Linux

Detailed explication for [Windows](https://lime.software/docs/advanced-setup/windows/) and [Linux](https://lime.software/docs/advanced-setup/linux/).

Simply... in Windows run:
```console
lime setup windows
```
or in Linux:
```console
lime setup linux
```
and follow the steps.

Later, just run "lime test windows -debug" (on Windows) or "lime test linux -debug" (on Linux) in the root folder.

## Docker

The Dockerfile was made to build Linux and Android more easily. **ONLY WORK ON LINUX**

```console
# docker build -t grapesoda .
# docker run -v "$PWD":/opt/FlxGrapeSoda grapesoda          #Compile for Android
# docker run -v "$PWD":/opt/FlxGrapeSoda grapesoda linux    #Compile for Linux
```