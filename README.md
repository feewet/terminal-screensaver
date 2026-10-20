# terminal-screensaver

Every new terminal tab opens on a random animated scene from
[ascii-magic.com](https://www.ascii-magic.com/ascii). Press any key to get your prompt.

Nothing is fetched when a tab opens. The art and its player are cloned once, at a pinned commit,
and the launcher refuses to play anything else.

## Requirements

- zsh
- Node.js 18 or newer
- git

## Install

1. Clone the art and player at a pinned commit:

   ```sh
   git clone --no-checkout https://github.com/kailashsr38/ascii-magic-art ~/.local/share/ascii-magic-art &&
   git -C ~/.local/share/ascii-magic-art checkout de88962156057cbef583bd265bf55e23d6c5e30d
   ```

   `--no-checkout` keeps upstream's latest code off disk. If the checkout fails, nothing is there
   to run.

2. Pick the scenes to rotate through. Each file in `screensavers/` is one option. Only its name
   matters, so the files are empty:

   ```sh
   mkdir -p ~/.local/share/ascii-magic-art/screensavers
   cd ~/.local/share/ascii-magic-art/screensavers
   for s in orbit-window-earth summit-cloud-sea train-at-dusk cliff-lighthouse-night river-lantern-festival; do
     touch $s.js
   done
   ```

3. Install the launcher from this repo:

   ```sh
   mkdir -p ~/.local/bin
   install -m 755 terminal-screensaver ~/.local/bin/terminal-screensaver
   ```

   The launcher looks for Node at `/opt/homebrew/bin/node` and `/usr/local/bin/node`, not on
   `$PATH`. If yours is elsewhere (nvm, volta...), add its absolute path to the `for NODE` line
   in `~/.local/bin/terminal-screensaver`.

4. Add this to the **top** of `~/.zshrc`:

   ```zsh
   # Screensaver on new interactive terminal tabs; SCREENSAVER=0 disables.
   if [[ -o interactive && -t 0 && -t 1 && -z $SCREENSAVER_SHOWN && $SCREENSAVER != 0 \
         && -z $TMUX && -z $SSH_TTY && -z $CLAUDECODE \
         && $TERM_PROGRAM != vscode && $TERMINAL_EMULATOR != JetBrains-JediTerm ]]; then
     export SCREENSAVER_SHOWN=1
     $HOME/.local/bin/terminal-screensaver
   fi
   ```

   This block skips scripts, piped shells, nested shells, tmux, SSH, IDE terminals, and Claude Code.

5. Open a new tab.

## Add a screensaver

1. Find a scene on [ascii-magic.com/ascii](https://www.ascii-magic.com/ascii). Its name is the last
   part of the URL. For `https://www.ascii-magic.com/ascii/train-at-dusk`, the name is `train-at-dusk`.
2. Add an empty file with that name to the folder:

   ```sh
   touch ~/.local/share/ascii-magic-art/screensavers/train-at-dusk.js
   ```

3. Check that it plays:

   ```sh
   node ~/.local/share/ascii-magic-art/bin/cli.js train-at-dusk
   ```

The player can only play scenes that exist in its pinned copy. A scene published after that commit
is skipped silently.

To remove a scene, delete its file from `screensavers/`.

## Update the pin

Newer scenes need a newer commit, and every piece is code that runs on each new tab. Review what
changed before you move:

```sh
cd ~/.local/share/ascii-magic-art
git fetch
git diff HEAD <new-commit> -- bin lib runtime pieces
git checkout <new-commit>
```

Then set `PIN=` in `~/.local/bin/terminal-screensaver` to the new commit. Until you do, the
launcher plays nothing.

## Use

- Skip it once: `SCREENSAVER=0 zsh`
- Play it now: `terminal-screensaver`
- The key that stops a scene is swallowed, and so is anything typed or pasted along with it.
  Wait for the prompt before you type.
- Uninstall: delete the `~/.zshrc` block, `~/.local/bin/terminal-screensaver`, and
  `~/.local/share/ascii-magic-art`.

## Credits

The art and player are from [ascii-magic-art](https://github.com/kailashsr38/ascii-magic-art)
(MIT). This repo only holds the launcher and these instructions.
