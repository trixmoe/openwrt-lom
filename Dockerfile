FROM debian:12

# Install dependencie
RUN apt update && apt-get upgrade -y && \
    apt install -y bash bash-completion sudo tmux vim git git-doc git-extras git-filter-repo tig \
        build-essential clang flex bison g++ gawk gettext git libncurses5-dev libssl-dev python3-setuptools rsync swig unzip zlib1g-dev file wget rsync && \
    ( apt install -y gcc-multilib g++-multilib || echo "WARNING: Not install gcc-multilib, as they are not available. This is a known quirk of arm64.")

ARG HOME_DIR=/build/
ARG PROJ_DIR=$HOME_DIR/openwrt/

# Allow NOPASSWD sudo
RUN sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g'

# Create build user, clone project
RUN useradd -mG sudo -d $HOME_DIR -s /bin/bash build
USER build
RUN mkdir $PROJ_DIR
WORKDIR $PROJ_DIR
COPY . .
RUN make update
