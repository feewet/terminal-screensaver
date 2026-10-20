#!/bin/zsh
# Installs terminal-screensaver: clones the art at the pinned commit, enables every scene except
# app screens, empty states and dividers, installs the launcher, and adds the hook to ~/.zshrc.
# Safe to run again: it only fills in what is missing.
set -e
cd "$(dirname "$0")"
APP=$HOME/.local/share/ascii-magic-art
PIN=$(sed -n 's/^PIN=//p' terminal-screensaver)

for NODE in /opt/homebrew/bin/node /usr/local/bin/node; do [[ -x $NODE ]] && break; done
[[ -x $NODE ]] || { echo "Node not found at /opt/homebrew/bin/node or /usr/local/bin/node. Install it or edit the 'for NODE' line in terminal-screensaver."; exit 1; }

# 1. Art and player, at the pinned commit only.
if [[ ! -d $APP/.git ]]; then
  git clone --quiet --no-checkout https://github.com/kailashsr38/ascii-magic-art "$APP"
fi
git -C "$APP" checkout --quiet "$PIN"
echo "art: $APP at $PIN"

# 2. Scenes: all pieces except the screens, empty-states and frames categories.
mkdir -p "$APP/screensavers"
for p in "$APP"/pieces/*.js; do touch "$APP/screensavers/${p:t}"; done
for p in $(grep -lE 'category: "(screens|empty-states|frames)"' "$APP"/pieces/*.js); do rm -f "$APP/screensavers/${p:t}"; done
echo "scenes: $(ls "$APP/screensavers" | wc -l | tr -d ' ') enabled in $APP/screensavers"

# 3. Launcher.
mkdir -p "$HOME/.local/bin"
install -m 755 terminal-screensaver "$HOME/.local/bin/terminal-screensaver"
echo "launcher: $HOME/.local/bin/terminal-screensaver"

# 4. Shell hook, at the top of ~/.zshrc so it runs before anything that prints.
ZSHRC=$HOME/.zshrc
if ! grep -q 'local/bin/terminal-screensaver' "$ZSHRC" 2>/dev/null; then
  [[ -f $ZSHRC ]] && cp "$ZSHRC" "$ZSHRC.bak"
  { cat <<'HOOK'
# Screensaver on new interactive terminal tabs; SCREENSAVER=0 disables.
if [[ -o interactive && -t 0 && -t 1 && -z $SCREENSAVER_SHOWN && $SCREENSAVER != 0 \
      && -z $TMUX && -z $SSH_TTY && -z $CLAUDECODE \
      && $TERM_PROGRAM != vscode && $TERMINAL_EMULATOR != JetBrains-JediTerm ]]; then
  export SCREENSAVER_SHOWN=1
  $HOME/.local/bin/terminal-screensaver
fi

HOOK
    [[ -f $ZSHRC ]] && cat "$ZSHRC"; } > "$ZSHRC.new" && mv "$ZSHRC.new" "$ZSHRC"
  echo "hook: added to the top of $ZSHRC (backup: $ZSHRC.bak)"
else
  echo "hook: already in $ZSHRC"
fi

echo "Done. Open a new tab."
