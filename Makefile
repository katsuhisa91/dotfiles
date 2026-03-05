FILES = .gitconfig .vimrc
ZPREZTO_FILES = .zshrc .zpreztorc
VSCODE_FILES = settings.json
WEZTERM_FILES = wezterm.lua

VSCODE_PATH = $$HOME/Library/ApplicationSupport/Code/User
WEZTERM_PATH = $$HOME/.config/wezterm

PWD := $(shell pwd)


setup:
	@echo Install Prezto if not exists...
	if [ ! -d "$$HOME/.zprezto" ]; then \
		git clone --recursive https://github.com/sorin-ionescu/prezto.git "$$HOME/.zprezto"; \
	fi
	@echo Link Prezto runcoms...
	zsh -c 'setopt EXTENDED_GLOB; for rcfile in $$HOME/.zprezto/runcoms/^README.md(.N); do ln -sf $$rcfile $$HOME/.${rcfile:t}; done'

	@echo Making symlinks to dotfiles...
	for f in $(FILES); do \
		rm -f $$HOME/$$f; \
		ln -s $(PWD)/$$f $$HOME/$$f; \
	done

	@echo Put zprezto dotfiles...
	for zpreztof in $(ZPREZTO_FILES); do \
		cp -f $(PWD)/prezto/$$zpreztof $$HOME/$$zpreztof; \
	done

	@echo Put vscode dotfiles...
	mkdir -p $(VSCODE_PATH)
	for vscodef in $(VSCODE_FILES); do \
		cp -f $(PWD)/vscode/$$vscodef $(VSCODE_PATH)/$$vscodef; \
	done

	@echo Put wezterm dotfiles...
	mkdir -p $(WEZTERM_PATH)
	for weztermf in $(WEZTERM_FILES); do \
		cp -f $(PWD)/wezterm/$$weztermf $(WEZTERM_PATH)/$$weztermf; \
	done

	@echo Deploy Claude global settings...
	mkdir -p $$HOME/.claude
	cp -f $(PWD)/.claude/settings.json $$HOME/.claude/settings.json
	cp -f $(PWD)/.claude/CLAUDE.md $$HOME/.claude/CLAUDE.md

.PHONY:	setup