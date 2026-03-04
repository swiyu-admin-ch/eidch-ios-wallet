.DEFAULT_GOAL := generate

# ANSI color codes
RESET := \033[0m
GREEN := \033[0;32m
BLUE := \033[0;34m

# Main setup target
setup: .install-mise .configure-mise .install-mise-tools .bundler .list-tools .list-tasks .warm generate
	@printf "$(GREEN)=> Setup completed successfully!$(RESET)\n"
	@printf "$(BLUE)=> Opening up swiyu$(RESET)\n"
	@printf "$(BLUE)=> Note: From now on, you can simply use make to open the project$(RESET)\n"

setup-ci: .install-mise-github-action .install-mise-tools
	@printf "$(GREEN)=> Setup CI completed successfully!$(RESET)\n"

# Check if mise is installed, install if not
.install-mise:
	@if command -v mise >/dev/null 2>&1; then \
		printf "$(BLUE)=> Mise is already installed, skipping installation$(RESET)\n"; \
		mise self-update -y || true; \
	else \
		printf "$(GREEN)=> Installing mise$(RESET)\n"; \
		curl https://mise.run | sh; \
		echo 'eval "$$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc; \
		exec zsh; \
		mise doctor; \
		printf "$(GREEN)=> Mise installed successfully!$(RESET)\n"; \
	fi

# Check if mise is installed, install if not
.install-mise-github-action:
	@if command -v mise >/dev/null 2>&1; then \
		printf "$(BLUE)=> Mise is already installed, skipping installation$(RESET)\n"; \
		mise self-update -y || true; \
	else \
		printf "$(GREEN)=> Installing mise$(RESET)\n"; \
		curl https://mise.run | sh; \
		echo 'eval "$$(~/.local/bin/mise activate bash)"' >> ~/.bashrc; \
		exec bash; \
		mise doctor; \
		printf "$(GREEN)=> Mise installed successfully!$(RESET)\n"; \
	fi

# Configure mise settings
.configure-mise:
	@printf "$(GREEN)=> Configuring mise$(RESET)\n"
	mise settings experimental=true & mise generate git-pre-commit --write --task=pre-commit

# Install tools defined in mise configuration
.install-mise-tools:
	@printf "$(GREEN)=> Installing tools$(RESET)\n"
	mise trust
	mise settings experimental=true
	mise install

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
	mise build-project

.warm: 
	@printf "$(GREEN)=> Warming project$(RESET)\n"
	mise xcodegen
.generate-project:
	mise generate-project
.regenerate-project:
	mise regenerate-project

# Help target - only public target besides setup
help:
	@echo "Available targets:"
	@echo "  setup                    - Project setup"
	@echo "  generate (gen)           - Generate & Open project"
	@echo "  regenerate (regen)       - Regenerate & Open project without applying formatting tools (swiftgen, swiftformat, ...)"
	@echo "  help                     - Show this help message"
	@echo "mise tasks"

.PHONY: setup help generate gen regenerate regen