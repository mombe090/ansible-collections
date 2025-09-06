!#!/bin/bash

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew update
packages=(
  bat
  duf
  detect-secrets
  eza
  jq
  neovim
  pre-commit
  ripgrep
  sd
  starship
  stow
  tldr
  vivid
  zellij
  zoxide
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
)

for pkg in "${packages[@]}"; do
  brew install "$pkg" || true
done

brew cleanup
