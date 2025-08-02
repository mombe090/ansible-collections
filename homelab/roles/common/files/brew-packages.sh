!#!/bin/bash

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew update
packages=(
  argocd
  awscli
  bat
  checkov
  devcontainer
  duf
  detect-secrets
  eza
  figlet
  fluxcd/tap/flux
  gemini-cli
  jq
  k9s
  kubectl
  kubectx
  kustomize
  markdownlint-cli2
  neovim
  nodejs
  pre-commit
  ripgrep
  sd
  starship
  stow
  tfsec
  terraform-docs
  tldr
  uv
  vivid
  wget
  zellij
  zoxide
  kubecolor/tap/kubecolor
  bruno-cli
  helm
  jenv
  zsh
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
)

for pkg in "${packages[@]}"; do
  brew install "$pkg" || true
done

brew cleanup
