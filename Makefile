default: hello

update: ## Update modules
	@./scripts/update.sh

nupdate: ## Update modules (no backup)
	@./scripts/update.sh -n

dirclean: ## Delete module directories
	@./scripts/cleandir.sh

save: ## Save patches
	@./scripts/save-patches.sh

save-one: ## Only saves a single patchset
	@./scripts/save-patches.sh --one

generic: ## Apply generic patches
	@./scripts/apply-patches.sh generic

specific: generic # Apply patches for specific (kept for test.sh)
	@./scripts/apply-patches.sh specific

neoplus2: generic ## Apply patches for neoplus2
	@./scripts/apply-patches.sh neoplus2
	@./scripts/openwrt/prepare-feeds.sh

target2: generic ## Apply patches for target2
	@./scripts/apply-patches.sh target2
	@./scripts/openwrt/prepare-feeds.sh

docker: ## Build Docker image
	@./scripts/docker.sh all

build: ## Build OpenWRT
	@./scripts/openwrt/build.sh

rebuild: ## Rebuild OpenWrt (DIRTY but quicker)
	@./scripts/openwrt/build.sh --rebuild

qemu: ## Run built aarch64 files in QEMU (Quit: CTRL+A, then X)
	@./scripts/openwrt/qemu.sh

title: # Title
	@printf "\e[1mOpenWrt LOM\e[0m\n"

help-text: # Help info
	@echo
	@printf "Typical usage (once patches exist):\n"
	@printf "1.  make \e[1;35mdocker\e[0m - Build and run the Docker container (required from macOS)\n"
	@printf "1.1 \e[1;35mAttach IDE\e[0m or terminal to the container.\n"
	@printf "    It is expected that you are in the container, or a Linux environment with the required tools.\n"
	@echo
	@printf "2.  make \e[1;35mupdate\e[0m - Update modules\n"
	@echo
	@printf "3.  Run one of these commands:\n"
	@printf "    make \e[1;35mgeneric\e[0m - Only apply generic patches\n"
	@printf "    make \e[1;35mneoplus21\e[0m - Apply generic + neoplus2 patches\n"
	@printf "    make \e[1;35mtarget2\e[0m - Apply generic + target2 patches\n"
	@echo
	@printf "4.  make \e[1;35mbuild\e[0m - Build OpenWrt\n"
	@echo
	@printf "5.  make \e[1;35mqemu\e[0m - (\e[1;4;31mfrom your arm64 macOS\e[0m) Grab and run the arm64 build from the container as a VM\n"
	@echo
	@printf "6.  \e[1mAdd/Modify/Remove patches\e[0m\n"
	@printf "    \e[1;35mgit commit\e[0m/\e[1;35mgit rebase\e[0m/...: do changes\n"
	@printf "    \e[1;35mgit tag -f\e[0m: marks end of patchset (top-most commit) - force to overwrite prev. tag\n"
	@echo
	@printf "7.  make \e[1;35msave\e[0m - Save commits (tagged properly) to patch sets\n"

help: title help-text target-list ## Help: how to work with existing patches and build OpenWrt

hello: title target-list # List targets (default)

target-list:
	@echo
	@grep -E '^[a-z.A-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: *
.NOTPARALLEL:
.ONESHELL:
