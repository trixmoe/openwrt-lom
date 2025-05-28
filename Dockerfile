FROM debian:12

RUN apt update && apt-get upgrade -y && \
    apt install -y bash bash-completion sudo tmux vim git git-doc git-extras git-filter-repo tig \
        build-essential clang flex bison g++ gawk gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev python3-setuptools rsync swig unzip zlib1g-dev file wget rsync

RUN useradd -mG sudo -d /build/ build
USER build
