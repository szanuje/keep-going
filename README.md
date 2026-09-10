# keep-going

A tiny macOS command-line utility that keeps the Mac awake and, after a period
of inactivity, nudges the mouse cursor by 1 pixel and immediately restores it.
It runs until you press `Ctrl+C`.

## Install

Because this repository is private, installation uses your authenticated
GitHub CLI session.

Prerequisites:

- macOS
- [GitHub CLI](https://cli.github.com/) authenticated with `gh auth login`
- [Homebrew](https://brew.sh/) if `cliclick` is not already installed

Install with one command:

```sh
gh api repos/szanuje/keep-going/contents/install.sh \
  -H 'Accept: application/vnd.github.raw+json' | bash
```

The installer automatically:

- installs `cliclick` with Homebrew if needed;
- downloads the latest `keep-going` from `main`;
- installs it as `/usr/local/bin/keep-going`;
- makes it executable.

It may ask for your administrator password when writing to `/usr/local/bin`.

The terminal app that runs `keep-going` may also need permission under:

**System Settings → Privacy & Security → Accessibility**

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

### Custom install directory

To avoid installing into `/usr/local/bin`, set `KEEP_GOING_INSTALL_DIR`:

```sh
gh api repos/szanuje/keep-going/contents/install.sh \
  -H 'Accept: application/vnd.github.raw+json' | \
  KEEP_GOING_INSTALL_DIR="$HOME/.local/bin" bash
```

Make sure the chosen directory is in your `PATH`.

## How it works

`caffeinate -i` creates a macOS power-management assertion that prevents idle
system sleep while `keep-going` is running. Separately, `IOHIDSystem` exposes
the time since the last HID input event. Once that idle time reaches the
configured threshold, `cliclick` posts a tiny relative mouse movement and then
moves the pointer back to its original location.

This is intended for keeping long-running local processes and development
workflows alive. Synthetic presence may be treated differently by individual
applications or workplace policies.
