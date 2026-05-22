# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# PATH
export PATH=$HOME/bin:/rez/bin:$PATH

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git z github history macos pip pyenv pylint python sublime vscode zsh-autosuggestions fzf aws zsh-completions kubectl)

source $ZSH/oh-my-zsh.sh

# zsh-syntax-highlighting — try common locations
for f in \
  "$HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
  [ -f "$f" ] && source "$f" && break
done

export PATH=$PATH:$HOME/bin
export EDITOR='nvim'

# Ruby build flags (only if openssl@1.1 is installed)
if command -v brew >/dev/null 2>&1 && brew --prefix openssl@1.1 >/dev/null 2>&1; then
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
fi

# Aliases
alias myip='curl icanhazip.com'
alias upgrade='brew update && brew upgrade'
alias ic='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'
alias lt='exa --tree --level=2 --long --icons --git'
alias http='xh'
alias cdl='cd $(llama)'
alias sshproxy='ssh -o "ProxyCommand=nc -X 5 -x 127.0.0.1:1080 %h %p"'
alias v='nvim'
alias k='kubectl'
alias ggs='git log --oneline --decorate --all --graph'
alias persisOVPN='sudo openvpn --config ~/Projects/aradarpa/persis/ovpn/Persis-Asiatech.ovpn --auth-user-pass ~/Projects/aradarpa/persis/ovpn/auth.txt'

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Powerlevel10k user config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# hcloud completions
[ -d ~/.config/hcloud/completion/zsh ] && fpath+=(~/.config/hcloud/completion/zsh)
autoload -Uz compinit; compinit

# Cilium / Hubble
export HUBBLE_ARCH=arm64

# kubeconfig
[ -f ~/.kube/config_all ] && export KUBECONFIG=~/.kube/config_all

# --- Kubernetes helpers ---
# context / namespace shortcuts
command -v kubectx >/dev/null 2>&1 && alias kc='kubectx'
command -v kubens  >/dev/null 2>&1 && alias kn='kubens'

# Bulk-load shell completion for k8s tools that expose `completion zsh`.
for _k8s_cmd in helm kustomize talosctl cilium hubble k3d kind minikube velero argocd; do
  if command -v "$_k8s_cmd" >/dev/null 2>&1; then
    source <("$_k8s_cmd" completion zsh 2>/dev/null) 2>/dev/null
  fi
done
unset _k8s_cmd
command -v argocd >/dev/null 2>&1 && compdef _argocd argocd

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# kubetail completion (only if kubetail is installed)
if command -v kubetail >/dev/null 2>&1; then
  compdef _kubetail kubetail

  # zsh completion for kubetail                             -*- shell-script -*-

  __kubetail_debug()
  {
      local file="$BASH_COMP_DEBUG_FILE"
      if [[ -n ${file} ]]; then
          echo "$*" >> "${file}"
      fi
  }

  _kubetail()
  {
      local shellCompDirectiveError=1
      local shellCompDirectiveNoSpace=2
      local shellCompDirectiveNoFileComp=4
      local shellCompDirectiveFilterFileExt=8
      local shellCompDirectiveFilterDirs=16
      local shellCompDirectiveKeepOrder=32

      local lastParam lastChar flagPrefix requestComp out directive comp lastComp noSpace keepOrder
      local -a completions

      __kubetail_debug "\n========= starting completion logic =========="
      __kubetail_debug "CURRENT: ${CURRENT}, words[*]: ${words[*]}"

      words=("${=words[1,CURRENT]}")
      __kubetail_debug "Truncated words[*]: ${words[*]},"

      lastParam=${words[-1]}
      lastChar=${lastParam[-1]}
      __kubetail_debug "lastParam: ${lastParam}, lastChar: ${lastChar}"

      setopt local_options BASH_REMATCH
      if [[ "${lastParam}" =~ '-.*=' ]]; then
          flagPrefix="-P ${BASH_REMATCH}"
      fi

      requestComp="${words[1]} __complete ${words[2,-1]}"
      if [ "${lastChar}" = "" ]; then
          __kubetail_debug "Adding extra empty parameter"
          requestComp="${requestComp} \"\""
      fi

      __kubetail_debug "About to call: eval ${requestComp}"

      out=$(eval ${requestComp} 2>/dev/null)
      __kubetail_debug "completion output: ${out}"

      local lastLine
      while IFS='\n' read -r line; do
          lastLine=${line}
      done < <(printf "%s\n" "${out[@]}")
      __kubetail_debug "last line: ${lastLine}"

      if [ "${lastLine[1]}" = : ]; then
          directive=${lastLine[2,-1]}
          local suffix
          (( suffix=${#lastLine}+2))
          out=${out[1,-$suffix]}
      else
          __kubetail_debug "No directive found.  Setting do default"
          directive=0
      fi

      __kubetail_debug "directive: ${directive}"
      __kubetail_debug "completions: ${out}"
      __kubetail_debug "flagPrefix: ${flagPrefix}"

      if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
          __kubetail_debug "Completion received error. Ignoring completions."
          return
      fi

      local activeHelpMarker="_activeHelp_ "
      local endIndex=${#activeHelpMarker}
      local startIndex=$((${#activeHelpMarker}+1))
      local hasActiveHelp=0
      while IFS='\n' read -r comp; do
          if [ "${comp[1,$endIndex]}" = "$activeHelpMarker" ];then
              __kubetail_debug "ActiveHelp found: $comp"
              comp="${comp[$startIndex,-1]}"
              if [ -n "$comp" ]; then
                  compadd -x "${comp}"
                  __kubetail_debug "ActiveHelp will need delimiter"
                  hasActiveHelp=1
              fi
              continue
          fi

          if [ -n "$comp" ]; then
              comp=${comp//:/\\:}
              local tab="$(printf '\t')"
              comp=${comp//$tab/:}

              __kubetail_debug "Adding completion: ${comp}"
              completions+=${comp}
              lastComp=$comp
          fi
      done < <(printf "%s\n" "${out[@]}")

      if [ $hasActiveHelp -eq 1 ]; then
          if [ ${#completions} -ne 0 ] || [ $((directive & shellCompDirectiveNoFileComp)) -eq 0 ]; then
              __kubetail_debug "Adding activeHelp delimiter"
              compadd -x "--"
              hasActiveHelp=0
          fi
      fi

      if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
          __kubetail_debug "Activating nospace."
          noSpace="-S ''"
      fi

      if [ $((directive & shellCompDirectiveKeepOrder)) -ne 0 ]; then
          __kubetail_debug "Activating keep order."
          keepOrder="-V"
      fi

      if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
          local filteringCmd
          filteringCmd='_files'
          for filter in ${completions[@]}; do
              if [ ${filter[1]} != '*' ]; then
                  filter="\*.$filter"
              fi
              filteringCmd+=" -g $filter"
          done
          filteringCmd+=" ${flagPrefix}"
          __kubetail_debug "File filtering command: $filteringCmd"
          _arguments '*:filename:'"$filteringCmd"
      elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
          local subdir
          subdir="${completions[1]}"
          if [ -n "$subdir" ]; then
              __kubetail_debug "Listing directories in $subdir"
              pushd "${subdir}" >/dev/null 2>&1
          else
              __kubetail_debug "Listing directories in ."
          fi

          local result
          _arguments '*:dirname:_files -/'" ${flagPrefix}"
          result=$?
          if [ -n "$subdir" ]; then
              popd >/dev/null 2>&1
          fi
          return $result
      else
          __kubetail_debug "Calling _describe"
          if eval _describe $keepOrder "completions" completions $flagPrefix $noSpace; then
              __kubetail_debug "_describe found some completions"
              return 0
          else
              __kubetail_debug "_describe did not find completions."
              __kubetail_debug "Checking if we should do file completion."
              if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
                  __kubetail_debug "deactivating file completion"
                  return 1
              else
                  __kubetail_debug "Activating file completion"
                  _arguments '*:filename:_files'" ${flagPrefix}"
              fi
          fi
      fi
  }
fi

# bash completion compatibility
autoload -U +X bashcompinit && bashcompinit

# MinIO client completion
[ -x /opt/homebrew/bin/mc ] && complete -o nospace -C /opt/homebrew/bin/mc mc

# Google Cloud SDK
[ -f /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ] && \
  source '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'

export PATH="$HOME/.local/bin:$PATH"

# Antigravity (only if installed)
[ -d "$HOME/.antigravity/antigravity/bin" ] && \
  export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Google Cloud project defaults
export MODEL_ID="gemini-3.1-pro-preview"
export PROJECT_ID="fedshi-non-prod"
export GOOGLE_CLOUD_PROJECT="fedshi-non-prod"
export GOOGLE_CLOUD_LOCATION="global"

# Machine-local / secret environment (not tracked in git)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
