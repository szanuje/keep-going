# keep-going

A tiny macOS command-line utility that keeps the Mac awake and, after a period
of inactivity, nudges the mouse cursor by 1 pixel and immediately restores it.
It runs until you press `Ctrl+C`.

## Requirements

- macOS
- [Homebrew](https://brew.sh/)
- [`cliclick`](https://github.com/BlueM/cliclick)

```sh
brew install cliclick
```

The terminal app that runs `keep-going` may need permission under:

**System Settings → Privacy & Security → Accessibility**

## Install from this private repository

Because the repository is private, an unauthenticated `raw.githubusercontent.com`
URL cannot be used. If GitHub CLI is authenticated with access to the repo:

```sh
tmp="$(mktemp)" && \
  gh api repos/szanuje/keep-going/contents/keep-going \
    -H 'Accept: application/vnd.github.raw+json' > "$tmp" && \
  sudo install -m 0755 "$tmp" /usr/local/bin/keep-going; \
  status=$?; rm -f "$tmp"; exit "$status"
```

This uses your existing `gh` authentication; no token needs to be copied into
the command line. GitHub's Contents API supports returning raw file bytes via
its `application/vnd.github.raw+json` media type.

If you prefer a user-owned install location:

```sh
mkdir -p ~/.local/bin
tmp="$(mktemp)" && \
  gh api repos/szanuje/keep-going/contents/keep-going \
    -H 'Accept: application/vnd.github.raw+json' > "$tmp" && \
  install -m 0755 "$tmp" ~/.local/bin/keep-going; \
  status=$?; rm -f "$tmp"; exit "$status"
```

Make sure `~/.local/bin` is in your `PATH`.

## Install with curl if the repository becomes public

```sh
tmp="$(mktemp)" && \
  curl -fsSL https://raw.githubusercontent.com/szanuje/keep-going/main/keep-going -o "$tmp" && \
  sudo install -m 0755 "$tmp" /usr/local/bin/keep-going; \
  status=$?; rm -f "$tmp"; exit "$status"
```

## Usage

```sh
keep-going
```

Stop it with `Ctrl+C`.

Defaults:

- prevent macOS idle system sleep while running;
- allow the display to sleep normally;
- after 5 minutes of real user inactivity, move the cursor by 1 pixel and back;
- check for inactivity every 15 seconds.

While you are actively using the keyboard or mouse, it does not move the
cursor.

### Configuration

```sh
KEEP_GOING_IDLE_SECONDS=300 \
KEEP_GOING_CHECK_SECONDS=15 \
KEEP_GOING_JIGGLE_PIXELS=1 \
keep-going
```

Example: jiggle after 4 minutes of inactivity:

```sh
KEEP_GOING_IDLE_SECONDS=240 keep-going
```

## How it works

`caffeinate -i` creates a macOS power-management assertion that prevents idle
system sleep while `keep-going` is running. Separately, `IOHIDSystem` exposes
the time since the last HID input event. Once that idle time reaches the
configured threshold, `cliclick` posts a tiny relative mouse movement and then
moves the pointer back to its original location.

This is intended for keeping long-running local processes and development
workflows alive. Synthetic presence may be treated differently by individual
applications or workplace policies.
