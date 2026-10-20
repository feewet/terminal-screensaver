# terminal-screensaver

Every new terminal tab opens on a random animated scene from
[ascii-magic.com](https://www.ascii-magic.com/ascii). Press any key to get your prompt; the key
you pressed is already typed there, as in any other tab.

Nothing is fetched when a tab opens. The art and its player are cloned once, at a pinned commit,
and the launcher refuses to play anything else.

## Requirements

- zsh (with the `zsh/zselect` module, included on macOS and in standard builds)
- Node.js 18 or newer, at `/opt/homebrew/bin/node` or `/usr/local/bin/node`
- git

## Install

```sh
git clone https://github.com/feewet/terminal-screensaver
cd terminal-screensaver
./install.sh
```

Then open a new tab. The script:

1. Clones the art and player to `~/.local/share/ascii-magic-art` and checks out a pinned commit.
   The launcher refuses to play any other commit.
2. Enables 526 of the 634 pieces as scenes: everything except app screens, empty states and page
   dividers (the upstream `screens`, `empty-states` and `frames` categories).
3. Copies the launcher to `~/.local/bin/terminal-screensaver`.
4. Adds the hook below to the top of `~/.zshrc` (backup in `~/.zshrc.bak`). It skips scripts,
   piped shells, nested shells, tmux, SSH, IDE terminals, and Claude Code.

   ```zsh
   # Screensaver on new interactive terminal tabs; SCREENSAVER=0 disables.
   if [[ -o interactive && -t 0 && -t 1 && -z $SCREENSAVER_SHOWN && $SCREENSAVER != 0 \
         && -z $TMUX && -z $SSH_TTY && -z $CLAUDECODE \
         && $TERM_PROGRAM != vscode && $TERMINAL_EMULATOR != JetBrains-JediTerm ]]; then
     export SCREENSAVER_SHOWN=1
     $HOME/.local/bin/terminal-screensaver
   fi
   ```

Running it again only fills in what is missing. Each step is a plain command in `install.sh` if
you would rather do them by hand.

The launcher looks for Node at `/opt/homebrew/bin/node` and `/usr/local/bin/node`, not on
`$PATH`. If yours is elsewhere (nvm, volta...), add its absolute path to the `for NODE` line in
`terminal-screensaver` before installing.

## Choose scenes

Each file in `~/.local/share/ascii-magic-art/screensavers/` is one option. Only its name matters,
so the files are empty. Delete a file to drop that scene.

Everything, all 634 pieces:

```sh
cd ~/.local/share/ascii-magic-art
for p in pieces/*.js; do touch screensavers/${p:t}; done
```

Only the 167 pieces upstream tags `wallpaper`, full-screen scenes and nothing else:

```sh
cd ~/.local/share/ascii-magic-art
rm -f screensavers/*.js
for p in $(grep -l '"wallpaper"' pieces/*.js); do touch screensavers/${p:t}; done
```

A hand-picked few:

```sh
cd ~/.local/share/ascii-magic-art
rm -f screensavers/*.js
for s in orbit-window-earth summit-cloud-sea train-at-dusk cliff-lighthouse-night river-lantern-festival; do
  touch screensavers/$s.js
done
```

One scene by name. The name is the last part of its URL on
[ascii-magic.com/ascii](https://www.ascii-magic.com/ascii): for
`https://www.ascii-magic.com/ascii/train-at-dusk` it is `train-at-dusk`.

```sh
touch ~/.local/share/ascii-magic-art/screensavers/train-at-dusk.js
node ~/.local/share/ascii-magic-art/bin/cli.js train-at-dusk   # check that it plays
```

The player can only play scenes that exist in its pinned copy. A scene published after that commit
is skipped silently.

## Update the pin

Newer scenes need a newer commit, and every piece is code that runs on each new tab. Review what
changed before you move:

```sh
cd ~/.local/share/ascii-magic-art
git fetch
git diff HEAD <new-commit> -- bin lib runtime pieces
git checkout <new-commit>
```

Then set `PIN=` in this repo's `terminal-screensaver` to the new commit and run `./install.sh`
again. Until you do, the launcher plays nothing.

## Use

- Skip it once: `SCREENSAVER=0 zsh`
- Play it now: `terminal-screensaver`
- The key that stops a scene is not lost: it is the first character at your prompt. Pastes
  arrive whole.
- Uninstall: delete the `~/.zshrc` block, `~/.local/bin/terminal-screensaver`, and
  `~/.local/share/ascii-magic-art`.

## Credits

The art and player are from [ascii-magic-art](https://github.com/kailashsr38/ascii-magic-art)
(MIT). This repo only holds the launcher, the install script and these instructions.
