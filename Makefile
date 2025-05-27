SHELL := /bin/bash
.DEFAULT_GOAL := generate

# Paths
XCODEGEN ?= xcodegen
SWIFTGEN ?= swiftgen
SWIFTFORMAT ?= swiftformat
PROJECT := swiyu.xcodeproj
LOCK_DIR := /tmp/build_module_lock

# ANSI color codes
RESET := \033[0m
GREEN := \033[0;32m
YELLOW := \033[0;33m
CYAN := \033[0;36m
RED := \033[0;31m
BLUE := \033[0;34m

# Performance
NCPU := $(shell sysctl -n hw.ncpu)

# SPM
SPM_DIRS := $(shell find Modules/Features Modules/Platforms -type d -mindepth 1 -maxdepth 1)

.PHONY: clean-locks

install: 
	@printf "$(GREEN)=> Install dependencies$(RESET)\n"
	brew update
	brew bundle
	bundle install

clean-locks:
	@rm -rf $(LOCK_DIR)

generate-project: generate-info-plist generate-swiftgen
	@printf "$(GREEN)✨ Project generation complete$(RESET)\n"

generate-info-plist:
	@printf "          $(YELLOW)⠋ Generating Info.plist$(RESET)\r"
	@if ! $(XCODEGEN) generate 2>/dev/null >/dev/null; then \
		printf "          $(RED)✗ Generating Info.plist - Failed$(RESET)\n"; \
		exit 1; \
	fi
	@printf "          $(GREEN)✓ Generating Info.plist$(RESET)\n"

generate-swiftgen:
	@printf "          $(YELLOW)⠋ Generating Assets using SwiftGen$(RESET)\r"
	@if ! $(SWIFTGEN) 2>/dev/null >/dev/null; then \
		printf "          $(RED)✗ Generating Assets - Failed$(RESET)\n"; \
		exit 1; \
	fi
	@printf "          $(GREEN)✓ Generating Assets using SwiftGen$(RESET)\n"

prepare-modules: clean-locks
	@printf "\n$(CYAN)═══════════════════════════ Processing Modules ════════════════════════$(RESET)\n"
	@mkdir -p $(LOCK_DIR)
	@printf "%s\n" $(SPM_DIRS) | sort | xargs -P $(NCPU) -n 1 ./Scripts/build_module.sh
	@printf "          $(GREEN)✓ All modules processed$(RESET)\n"
	@rm -rf $(LOCK_DIR)

format:
	@printf "\n$(CYAN)═══════════════════════════ Formatting Code ═══════════════════════════$(RESET)\n"
	@printf "          $(YELLOW)⠋ Formatting project code$(RESET)\r"
	@if ! $(SWIFTFORMAT) --quiet . 2>/dev/null >/dev/null; then \
		printf "          $(RED)✗ Formatting project code - Failed$(RESET)\n"; \
		exit 1; \
	fi
	@printf "          $(GREEN)✓ Formatting project code$(RESET)\n"

open-project:
	@printf "$(GREEN)=> Opening $(PROJECT) using Xcode$(RESET)\n"
	@open "$(PROJECT)"

generate-all: generate-project format prepare-modules open-project

# Main targets
generate:
	@START_TIME=$$(date +%s); \
	$(MAKE) -f $(firstword $(MAKEFILE_LIST)) generate-all; \
	END_TIME=$$(date +%s); \
	ELAPSED_TIME=$$((END_TIME - START_TIME)); \
	printf "$(GREEN)✨ All tasks completed successfully in $(BLUE)%d seconds$(RESET)\n" $$ELAPSED_TIME

setup: install generate
	@printf "$(GREEN)✨ Setup completed successfully$(RESET)\n"

.PHONY: install generate-project generate-info-plist generate-swiftgen prepare-modules format open-project generate generate-all setup
