ARG BASE_IMAGE=ghcr.io/games-on-whales/base:cachyos
#################################
FROM ${BASE_IMAGE} AS sdl-jstest-builder

WORKDIR /

ARG SDL_JS_TEST_VERSION=8a84a47209f96eb3994cf9f906ae072e828886bb
ENV SDL_JS_TEST_VERSION=${SDL_JS_TEST_VERSION}
RUN <<_BUILD_SDL_JSTEST
    set -e 

    pacman -Syu --noconfirm \
      automake \
      gcc \
      make \
      cmake \
      sdl2 \
      ncurses \
      git 

    git clone https://github.com/games-on-whales/sdl-jstest
    cd sdl-jstest
    git checkout ${SDL_JS_TEST_VERSION}
    git submodule init
    git submodule update
    mkdir build
    cd build
    cmake .. -DBUILD_SDL_JSTEST=OFF -DBUILD_SDL2_JSTEST=ON
    make

_BUILD_SDL_JSTEST

#################################
FROM ${BASE_IMAGE}

ARG GAMESCOPE_VERSION="3.16.22"
ENV GAMESCOPE_VERSION=$GAMESCOPE_VERSION

ARG PKGS_ROOT=/opt/gow

ARG REQUIRED_PACKAGES="\
    mesa vulkan-mesa-layers vulkan-radeon vulkan-intel vulkan-swrast libva-mesa-driver \
    egl-gbm egl-wayland \
    gamescope \
    sway swaybg gsettings-desktop-schemas \
    xorg-xwayland kitty nano \
    waybar mako noto-fonts xdg-desktop-portal xdg-desktop-portal-gtk psmisc \
    mangohud \
    sdl2 ncurses \
    procps-ng \
    dbus \
    libcap \
    "

RUN pacman -Syu --noconfirm $REQUIRED_PACKAGES && \
    pacman -Scc --noconfirm

COPY configs /cfg

COPY --chmod=777 scripts/init-gamescope.sh /etc/cont-init.d/init-gamescope.sh
COPY --chmod=777 scripts/launch-comp.sh /opt/gow/launch-comp.sh
COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh
COPY --from=sdl-jstest-builder /sdl-jstest/build/sdl2-jstest /usr/local/bin/sdl2-jstest

# Fix Sway cap_sys_nice=ep
RUN setcap -r /usr/bin/sway || true

# Configure the default directory to be the 'retro' users home directory
WORKDIR ${HOME}
