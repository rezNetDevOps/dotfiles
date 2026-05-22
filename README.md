# dotfiles

My personal Mac config — shell, editor, terminal. Pull this on a new machine, run
`install.sh`, and have the same setup everywhere.

## What's in here

| Where in repo            | Where it links to              | What it is                       |
| ------------------------ | ------------------------------ | -------------------------------- |
| `home/.zshrc`            | `~/.zshrc`                     | zsh + oh-my-zsh + powerlevel10k  |
| `home/.p10k.zsh`         | `~/.p10k.zsh`                  | Powerlevel10k prompt config      |
| `home/.tmux.conf`        | `~/.tmux.conf`                 | tmux                             |
| `home/.gitconfig`        | `~/.gitconfig`                 | git user/options                 |
| `home/.bashrc`           | `~/.bashrc`                    | bash interactive                 |
| `home/.bash_profile`     | `~/.bash_profile`              | bash login                       |
| `home/.fzf.zsh`          | `~/.fzf.zsh`                   | fzf key bindings (zsh)           |
| `home/.fzf.bash`         | `~/.fzf.bash`                  | fzf key bindings (bash)          |
| `config/nvim/`           | `~/.config/nvim/`              | Neovim (LazyVim)                 |
| `config/ghostty/`        | `~/.config/ghostty/`           | Ghostty terminal                 |
| `Brewfile`               | n/a                            | CLI tools to install via `brew bundle` |

### Tools installed by the Brewfile

- **Shell / editor:** zsh, tmux, neovim, fzf, git, exa, xh
- **Kubernetes core:** kubectl, helm, kustomize, k9s, kubetail, kubectx (gives `kubectx` + `kubens`)
- **GitOps:** argocd
- **Local clusters:** kind, k3d, minikube
- **Ops / debug:** velero, kubeshark, tilt
- **Cilium / Hubble:** cilium-cli, hubble
- **Talos:** talosctl
- **VPN into clusters:** kubevpn
- **MinIO:** mc
- **Terminal:** Ghostty (cask) + CaskaydiaMono Nerd Font

`.zshrc` loads completions for these guarded by `command -v`, so a machine
missing any of them still opens a shell cleanly. `kc` → `kubectx`, `kn` →
`kubens`.

### What's NOT in the repo (machine-local)

Kubeconfigs and cluster credentials never leave the machine. The following
stay on each Mac and have to be set up there:

- `~/.kube/` — kubeconfigs (your `config_all` is sourced by `.zshrc` if present)
- `~/.config/argocd/` — argocd login tokens
- `~/.talos/` — talosconfig
- `~/.kubevpn/`, `~/.minikube/` — machine state

## Bootstrap a new Mac

```bash
# 1. Install Xcode CLI tools + Homebrew
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install all CLI tools from the Brewfile (zsh, tmux, nvim, fzf,
#    plus the full Kubernetes toolkit)
git clone https://github.com/rezNetDevOps/dotfiles.git ~/dotfiles
brew bundle --file=~/dotfiles/Brewfile
# (Ghostty is in the Brewfile above. If you also want iTerm2/kitty:)
# brew install --cask iterm2 kitty

# 3. oh-my-zsh + powerlevel10k
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-completions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$HOME/zsh-syntax-highlighting"

# 4. Run the installer (symlinks files from the repo into $HOME)
cd ~/dotfiles
./install.sh

# 5. Open a new shell.
```

## install.sh

```
./install.sh             # symlink everything (backs up existing files)
./install.sh --dry-run   # print what it would do
./install.sh --force     # overwrite existing symlinks without backup
```

Existing files at the target path are backed up to `<path>.bak.<timestamp>`
on first run. Re-running is safe — already-correct symlinks are left alone.

## Secrets

**Secrets are not in this repo.** `~/.zshrc` sources `~/.zshrc.local` at the
end if it exists. `install.sh` seeds `~/.zshrc.local` from
`home/.zshrc.local.example` on first run. Put per-machine env vars and
credentials there — it's gitignored.

## Updating

```bash
cd ~/dotfiles
# edit files in home/ or config/
git add -p && git commit -m "describe the change"
git push
```

On other machines: `git pull` — symlinks point into the repo, so the change
takes effect immediately.
