ARG UBUNTU_VERSION=18.04

FROM ubuntu:${UBUNTU_VERSION}
MAINTAINER SavanDev

# Install dependencies
RUN apt-get update -y && apt-get -y install \
    haxe \
    unzip \
    wget \
    openjdk-8-jdk \
    g++ \
    gcc-multilib \
    g++-multilib \
    git

# Install Haxe libraries
RUN mkdir -p ./haxelib && \
	haxelib setup ./haxelib && \
	haxelib install lime && \
    haxelib install openfl && \
    haxelib install flixel && \
    haxelib run lime setup flixel && \
    haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc

# Download Android tools
RUN mkdir -p /usr/src/android && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip -o /usr/src/android/sdk.zip && \
    wget https://dl.google.com/android/repository/android-ndk-r15c-linux-x86_64.zip -o /usr/src/android/ndk.zip

# Unzip SDK
RUN mkdir -p /usr/src/android/cmdline-tools && \
    cd /usr/src/android/cmdline-tools && \
    unzip ../sdk.zip && \
    mv ./cmdline-tools ./latest && \
    rm /usr/src/android/sdk.zip

# Install SDK
RUN cd /usr/src/android && \
    ./cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-26" "build-tools;31.0.0"

# Unzip NDK
RUN mkdir -p /usr/src/android/ndk && \
    cd /usr/src/android/ndk && \
    unzip ../ndk.zip && \
    mv ./android-ndk-r15c ./r15c && \
    rm /usr/src/android/ndk.zip

# Configure Lime
RUN haxelib run lime setup -alias -y && \
    lime config ANDROID_SDK /usr/src/android && \
    lime config ANDROID_NDK_ROOT /usr/src/android/ndk/r15c && \
    lime config JAVA_HOME $(dirname $(dirname $(readlink -f $(which javac)))) && \
    lime config ANDROID_SETUP true && \
    lime config

WORKDIR /opt/FlxGrapeSoda

ENTRYPOINT [ "lime", "build" ]
CMD [ "android" ]
