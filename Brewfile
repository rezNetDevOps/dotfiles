# Brewfile — installs the CLI tools assumed by this dotfiles repo.
#
# Usage on a new Mac:
#     brew bundle --file=~/dotfiles/Brewfile
#
# `brew bundle` is idempotent: already-installed formulas are skipped.

# ----------------------------------------------------------------------------
# Taps for non-core formulas
# ----------------------------------------------------------------------------
tap "siderolabs/tap"          # talosctl

# ----------------------------------------------------------------------------
# Shell environment
# ----------------------------------------------------------------------------
brew "zsh"
brew "tmux"
brew "neovim"
brew "fzf"
brew "git"
brew "exa"                    # used by `lt` alias
brew "xh"                     # used by `http` alias

# ----------------------------------------------------------------------------
# Kubernetes — core
# ----------------------------------------------------------------------------
brew "kubernetes-cli"         # kubectl
brew "helm"
brew "kustomize"
brew "k9s"                    # TUI
brew "kubetail"               # multi-pod log streaming
brew "kubectx"                # ships both `kubectx` and `kubens`

# ----------------------------------------------------------------------------
# Kubernetes — GitOps / CD
# ----------------------------------------------------------------------------
brew "argocd"

# ----------------------------------------------------------------------------
# Kubernetes — local clusters
# ----------------------------------------------------------------------------
brew "kind"
brew "k3d"
brew "minikube"

# ----------------------------------------------------------------------------
# Kubernetes — operations / debugging
# ----------------------------------------------------------------------------
brew "velero"                 # backup / restore
brew "kubeshark"              # traffic analyzer
brew "tilt"                   # dev environments

# ----------------------------------------------------------------------------
# Cilium / Hubble
# ----------------------------------------------------------------------------
brew "cilium-cli"
brew "hubble"

# ----------------------------------------------------------------------------
# Talos OS
# ----------------------------------------------------------------------------
brew "siderolabs/tap/talosctl"

# ----------------------------------------------------------------------------
# Networking into clusters
# ----------------------------------------------------------------------------
brew "kubevpn"

# ----------------------------------------------------------------------------
# Object storage
# ----------------------------------------------------------------------------
brew "minio/stable/mc"        # MinIO client (used in .zshrc completion)
