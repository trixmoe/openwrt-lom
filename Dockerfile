# base only contains the mininmum to do work with a mount (non-macOS, due to case insentitive filesystem)
FROM debian:12 AS base

# Installing packages: (1) tools (2) OpenWRT deps (3) hidden OpenWRT deps
RUN apt-get update && \
    apt-get upgrade -y && \
    apt install -y vim tmux ccache sudo git git-doc git-extras git-filter-repo tig bash bash-completion \
                build-essential asciidoc bash binutils bzip2 flex git g++ gcc time util-linux gawk gzip help2man intltool libelf-dev zlib1g-dev make libncurses-dev libssl-dev patch perl-modules libthread-queue-any-perl python3-dev swig unzip wget gettext xsltproc zlib1g-dev \
                rsync

# Installing packages (downstream of PatchWrt), dependency of newer OpenWrt versions
RUN apt install -y python3-setuptools

# Allow NOPASSWD sudo
RUN sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g'

# Fix locale
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

ARG BUILD_USER
ARG BUILD_ROOTDIR
ARG BUILD_PROJDIR
ENV BUILD_DIR="/${BUILD_ROOTDIR}/${BUILD_PROJDIR}"
ENV USR=$BUILD_USER

# OpenWRT buildsystem requires non-root user
RUN useradd -ms /bin/bash -G sudo $USR
WORKDIR $BUILD_DIR
RUN chown -R $USR /${BUILD_ROOTDIR}/
USER $USR
# Force theme for visual separation of windows if attached in VSCode
RUN mkdir .vscode
RUN echo '{"workbench.colorTheme": "Solarized Dark"}' > .vscode/settings.json

# builder acts as a from-scratch environment, appropriate for CI or testing
FROM base AS builder
# Minimal copy to allow for maximum caching
COPY --chown=$USR modules ./
COPY --chown=$USR scripts ./scripts
RUN ./scripts/update.sh
# Copy everything else that's important and might change more often
COPY --chown=$USR Makefile ./
COPY --chown=$USR patches ./patches
COPY --chown=$USR .git/ ./.git/
COPY --chown=$USR .gitignore ./

# toolchain extends builder with patches applied and toolchain compiled, for CI caching
FROM builder AS toolchain
RUN make neoplus2
RUN make toolchain
