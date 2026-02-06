# OpenWrt-LOM

Use an OpenWrt device as a VPN into your LOM network.

The repository is based off [PatchWrt](https://github.com/trixmoe/patchwrt), which facilitates maintenance of patches.

## Usage

Run `make help` for instructions and a list of targets, `make` for a list of targets.

Docker is not required, but enables easier development from macOS. The scripts expect usage of colima, and will use mounts and volumes to cache the build process, while still replicating changes from the container to the host.

If you make use of this, it is recommended to use VSCode's remote development feature.
