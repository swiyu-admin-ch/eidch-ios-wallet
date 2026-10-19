.DEFAULT_GOAL := generate

# ANSI color codes
RESET := \033[0m
GREEN := \033[0;32m
BLUE := \033[0;34m
RED := \033[0;31m

# Main setup target
setup: .install-mise .configure-mise .install-mise-tools .install-git-hooks .configure-xcode .bundler .list-tools .list-tasks .warm generate
	@printf "$(GREEN)=> Setup completed successfully!$(RESET)\n"
	@printf "$(BLUE)=> Opening up swiyu$(RESET)\n"
	@printf "$(BLUE)=> Note: From now on, you can simply use make to open the project$(RESET)\n"

setup-ci: .install-mise .install-mise-tools
	@printf "$(GREEN)=> Setup CI completed successfully!$(RESET)\n"

# Check if mise is installed, install it with Homebrew if not
.install-mise:
	@if command -v mise >/dev/null 2>&1; then \
		printf "$(BLUE)=> Mise is already installed, skipping installation$(RESET)\n"; \
		mise self-update -y || true; \
	elif command -v brew >/dev/null 2>&1; then \
		printf "$(GREEN)=> Installing mise with Homebrew$(RESET)\n"; \
		brew install mise; \
		shell_name=$$(basename "$${SHELL:-/bin/zsh}"); \
		case "$$shell_name" in \
			zsh|bash) \
				rc="$$HOME/.$${shell_name}rc"; \
				grep -qs 'mise activate' "$$rc" || echo 'eval "$$(mise activate '"$$shell_name"')"' >> "$$rc"; \
				printf "$(BLUE)=> Mise activation added to $$rc, run 'exec $$shell_name' to apply it$(RESET)\n"; \
				;; \
			*) \
				printf "$(BLUE)=> Add 'mise activate $$shell_name' to your shell config to activate mise$(RESET)\n"; \
				;; \
		esac; \
		mise doctor || true; \
		printf "$(GREEN)=> Mise installed successfully!$(RESET)\n"; \
	else \
		printf "$(RED)=> Homebrew is required to install mise automatically.$(RESET)\n"; \
		printf "$(RED)=> Install Homebrew (https://brew.sh) or mise (https://mise.jdx.dev/installing-mise.html), then run make setup again.$(RESET)\n"; \
		exit 1; \
	fi

# Configure mise settings
.configure-mise:
	@printf "$(GREEN)=> Configuring mise$(RESET)\n"
	mise settings experimental=true & mise generate git-pre-commit --write --task=quality:pre-commit

# Install tools defined in mise configuration
.install-mise-tools:
	@printf "$(GREEN)=> Installing tools$(RESET)\n"
	mise trust
	mise settings experimental=true
	mise install
	mise snyk-configuration

.install-git-hooks:
	@printf "$(GREEN)=> Configuring git hooks$(RESET)\n"
	mise setup:git-hooks

# Apply local Xcode editor preferences
.configure-xcode:
	@printf "$(GREEN)=> Configuring Xcode editor preferences$(RESET)\n"
	mise setup:xcode

# List installed tools
.list-tools:
	@printf "$(GREEN)=> Installed tools$(RESET)\n"
	mise ls

# List available tasks
.list-tasks:
	@printf "$(GREEN)=> Available tasks$(RESET)\n"
	mise tasks

.bundler:
	bundle install

generate: .generate-project
gen: generate

regenerate: .regenerate-project
regen: regenerate

.build: 
	mise project:build

.warm: 
	@printf "$(GREEN)=> Warming project$(RESET)\n"
	mise project:xcodegen
.generate-project:
	mise project:generate
.regenerate-project:
	mise project:regenerate

# Help target - only public target besides setup
help:
	@echo "Available targets:"
	@echo "  setup                    - Project setup"
	@echo "  generate (gen)           - Generate & Open project"
	@echo "  regenerate (regen)       - Regenerate & Open project without applying formatting tools (swiftgen, swiftformat, ...)"
	@echo "  clean-swiftpm            - Remove all .build and .swiftpm directories in the repo"
	@echo "  help                     - Show this help message"
	@echo "mise tasks"

clean-swiftpm:
	@.resources/scripts/clean_swiftpm_dirs.sh

.PHONY: setup help generate gen regenerate regen clean-swiftpm
