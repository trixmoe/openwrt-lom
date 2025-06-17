default: help

update: ## Update modules
	@./scripts/update.sh

dirclean: ## Delete modules
	@./scripts/remove-modules.sh

save: ## Save patches
	@./scripts/save-patches.sh

generic: ## Apply generic patches
	@./scripts/apply-patches.sh generic

neoplus2: generic ## Apply patches for neoplus2
	@./scripts/apply-patches.sh neoplus2

specific2: generic ## Apply patches for specific2
	@./scripts/apply-patches.sh specific2

docker: ## Build Docker image
	@./scripts/lom/docker.sh

build: ## Build OpenWrt
	@./scripts/lom/build.sh

ci-docker-build:
	@./scripts/lom/docker.sh build

ci-docker-run:
	@./scripts/lom/docker.sh run

ci-patch-neoplus2:
	@./scripts/lom/docker.sh patch neoplus2

ci-compile:
	@./scripts/lom/docker.sh compile

ci-copy:
	@./scripts/lom/docker.sh copy

help: ## Show interactive help
	@printf "\e[1mOpenWrt LOM\e[0m\n"
	@echo
	@echo   "Usage:"
	@printf "1. make \e[1;35mupdate\e[0m - Update all modules\n"
	@echo
	@printf "2. make \e[1;35mgeneric\e[0m - Only apply generic patches\n"
	@printf "2. make \e[1;35mneoplus2\e[0m - Apply generic + neoplus2 patches\n"
	@printf "2. make \e[1;35mspecific2\e[0m - Apply generic + specific2 patches\n"
	@echo
	@printf "3. make \e[1;35msave\e[0m - Save commits to patches\n"
	@echo
	@grep -E '^[a-z.A-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: *
.NOTPARALLEL:
.ONESHELL: