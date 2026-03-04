FILES = .gitconfig .vimrc
ZPREZTO_FILES = .zshrc .zpreztorc
VSCODE_FILES = settings.json
WEZTERM_FILES = wezterm.lua

VSCODE_PATH = $$HOME/Library/ApplicationSupport/Code/User
WEZTERM_PATH = $$HOME/.config/wezterm

PWD := $(shell pwd)

setup:
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
	for vscodef in $(VSCODE_FILES); do \
		cp -f $(PWD)/vscode/$$vscodef $(VSCODE_PATH)/$$vscodef; \
	done

	@echo Put wezterm dotfiles...
	mkdir -p $(WEZTERM_PATH)
	for weztermf in $(WEZTERM_FILES); do \
		cp -f $(PWD)/wezterm/$$weztermf $(WEZTERM_PATH)/$$weztermf; \
	done

.PHONY:	setup