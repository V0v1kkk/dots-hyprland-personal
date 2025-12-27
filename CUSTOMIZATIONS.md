# end-4/dots-hyprland Customizations

This document describes all modifications made in the end-4/dots-hyprland fork on the `vladimir-custom` branch.

## Table of Contents

- [end-4/dots-hyprland Customizations](#end-4dots-hyprland-customizations)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
    - [Key Changes](#key-changes)
    - [Fork Philosophy](#fork-philosophy)
  - [Changelog](#changelog)
    - [1. Remove fish, kitty, starship dependencies](#1-remove-fish-kitty-starship-dependencies)
    - [2. Replace kitty with wezterm in keybinds](#2-replace-kitty-with-wezterm-in-keybinds)
    - [3. Set wezterm as default terminal in kdeglobals](#3-set-wezterm-as-default-terminal-in-kdeglobals)
    - [4. Configure hypridle for OLED protection](#4-configure-hypridle-for-oled-protection)
      - [Idle timers:](#idle-timers)
      - [Removed:](#removed)
      - [TODO:](#todo)
    - [5. Integrate Catppuccin Macchiato into kdeglobals](#5-integrate-catppuccin-macchiato-into-kdeglobals)
      - [Color scheme](#color-scheme)
      - [Preserved user settings](#preserved-user-settings)
      - [Original values documentation](#original-values-documentation)
    - [6. Add nwg-displays and Catppuccin cursor](#6-add-nwg-displays-and-catppuccin-cursor)
      - [1. Added nwg-displays package](#1-added-nwg-displays-package)
      - [2. Catppuccin cursor](#2-catppuccin-cursor)
      - [3. Terminal in fuzzel](#3-terminal-in-fuzzel)
    - [7. WezTerm matugen color template](#7-wezterm-matugen-color-template)
      - [Created new template](#created-new-template)
      - [Updated config.toml](#updated-configtoml)
      - [What matugen does](#what-matugen-does)
      - [WezTerm integration](#wezterm-integration)
    - [8. Custom autostart apps and keybinds](#8-custom-autostart-apps-and-keybinds)
      - [Autostart Applications](#autostart-applications)
      - [Custom Keybinds](#custom-keybinds)
    - [9. Add documentation for fork customizations](#9-add-documentation-for-fork-customizations)
    - [10. Keyboard layouts and KDE Connect clipboard sync](#10-keyboard-layouts-and-kde-connect-clipboard-sync)
      - [Keyboard Layouts Configuration](#keyboard-layouts-configuration)
      - [KDE Connect Clipboard Sync (Hyprland only)](#kde-connect-clipboard-sync-hyprland-only)
    - [11. Add Catppuccin themes (GTK and cursors)](#11-add-catppuccin-themes-gtk-and-cursors)
    - [12. Remove unused configs (kitty, foot, fish)](#12-remove-unused-configs-kitty-foot-fish)
  - [Integration Guide](#integration-guide)
    - [Syncing with upstream](#syncing-with-upstream)
    - [Merge conflicts](#merge-conflicts)
    - [Post-merge verification](#post-merge-verification)
  - [Rollback Instructions](#rollback-instructions)
    - [Revert single change](#revert-single-change)
    - [Full rollback to upstream](#full-rollback-to-upstream)
    - [Partial rollback (kdeglobals → MaterialYouDark)](#partial-rollback-kdeglobals--materialyoudark)
  - [Contact and Support](#contact-and-support)

---

## Overview

This fork adapts the end-4/dots-hyprland configuration to personal preferences:

### Key Changes

- **Terminal**: kitty → WezTerm
- **Shell**: fish → zsh (oh-my-posh instead of starship)
- **Theme**: MaterialYouDark → Catppuccin Macchiato
- **OLED Protection**: automatic brightness control via ddcutil
- **Tools**: added nwg-displays for monitor configuration

### Fork Philosophy

- Direct editing of main files (no `dots/.config/hypr/custom/` overrides)
- Atomic commits with clear messages
- Original values preserved in comments for easy rollback
- All changes documented in this file

---

## Changelog

### 1. Remove fish, kitty, starship dependencies

**Commit**: `60f64c75` (25 Dec 2025)

**Modified files**:
- `sdata/dist-arch/illogical-impulse-fonts-themes/PKGBUILD`

**Description**:
Removed packages from dependencies list:
- `fish` - using zsh instead
- `kitty` - using WezTerm
- `starship` - using oh-my-posh

**Rationale**:
- User already has zsh configured with oh-my-posh
- Repository configuration contains zsh support in `dots/.config/zshrc.d/`
- WezTerm chosen as primary terminal

**Impact**:
- PKGBUILD no longer installs unnecessary packages
- Reduced dependencies during installation

---

### 2. Replace kitty with wezterm in keybinds

**Commit**: `35279d24` (25 Dec 2025)

**Modified files**:
- `dots/.config/hypr/hyprland/keybinds.conf`

**Description**:
All terminal-related keybinds changed from `kitty -1` to `wezterm`:

| Keybind | Before | After |
|---------|--------|-------|
| Super + Return | `kitty -1` | `wezterm` |
| Super + T | `kitty -1` | `wezterm` |
| Ctrl + Alt + T | `kitty -1` | `wezterm` |
| Super + E (fallback) | `kitty -1 fish -c yazi` | `wezterm -e yazi` |
| Super + C (fallback) | `kitty -1 nvim` / `kitty -1 micro` | `wezterm -e nvim` / `wezterm -e micro` |
| Ctrl + Shift + Escape (fallback) | `kitty -1 fish -c btop` | `wezterm -e btop` |

**Additional changes**:
- Removed fish shell dependency from commands
- Fallback commands for yazi, nvim/micro, btop now use standard shell

**Impact**:
- WezTerm opens on main terminal keybinds
- All TUI applications launch in WezTerm

---

### 3. Set wezterm as default terminal in kdeglobals

**Commit**: `23f5cad0` (25 Dec 2025)

**Modified files**:
- `dots/.config/kdeglobals`

**Description**:
Changed `TerminalApplication` parameter in `[General]` section:
```ini
# Before:
TerminalApplication=kitty -1

# After:
TerminalApplication=wezterm
```

**Rationale**:
WezTerm integration with KDE apps (e.g., F4 in Dolphin).

**Impact**:
- Dolphin and other KDE apps open WezTerm when launching terminal
- KDE integration now uses the same terminal as Hyprland

---

### 4. Configure hypridle for OLED protection

**Commit**: `36a355e8` (25 Dec 2025)

**Modified files**:
- `dots/.config/hypr/hypridle.conf`

**Description**:

#### Idle timers:

**10 minutes → dim OLED to 10%**:
```bash
timeout = 600
on-timeout = ddcutil setvcp 10 10 --bus 6
on-resume = ddcutil setvcp 10 100 --bus 6
```
- OLED monitor (YMK EM160 TOUCH, HDMI-A-2, bus 6)
- Brightness reduced to 10% for burn-in protection
- On resume - restore to 100%

**15 minutes → DPMS off (monitors off)**:
```bash
timeout = 900
on-timeout = hyprctl dispatch dpms off
on-resume = hyprctl dispatch dpms on
```
- Complete backlight shutdown for both monitors
- Maximum OLED protection from static images

#### Removed:

- ❌ Auto-lock (hyprlock) - home PC, manual control only
- ❌ Auto-suspend (systemctl suspend) - not needed
- ❌ `--async` flag for ddcutil - deprecated since ddcutil 2.0+

#### TODO:

- 🔲 Test LG TV brightness control (HDMI-A-3, bus 8) after first Hyprland boot
  - CLI bus detection doesn't work with NVIDIA in KDE
  - May work in Hyprland without PowerDevil

**Rationale**:
- OLED screen requires burn-in protection
- Home PC, no lock needed
- Auto-suspend interferes with long-running tasks

**Impact**:
- OLED monitor dims after 10 minutes idle
- Both monitors turn off after 15 minutes
- No automatic locking or suspend

---

### 5. Integrate Catppuccin Macchiato into kdeglobals

**Commit**: `4e6b1acc` (25 Dec 2025)

**Modified files**:
- `dots/.config/kdeglobals` (complete color scheme replacement)

**Description**:

#### Color scheme

Replaced **MaterialYouDark** theme (end-4) with **Catppuccin Macchiato**:

| Section | Changes |
|---------|---------|
| `[Colors:Button]` | All Catppuccin Macchiato colors |
| `[Colors:Selection]` | All Catppuccin Macchiato colors |
| `[Colors:Tooltip]` | All Catppuccin Macchiato colors |
| `[Colors:View]` | All Catppuccin Macchiato colors |
| `[Colors:Window]` | All Catppuccin Macchiato colors |
| `[Colors:Complementary]` | All Catppuccin Macchiato colors |
| `[Colors:Header]` | All Catppuccin Macchiato colors |

#### Preserved user settings

- **Icons**: `Catppuccin-Macchiato` (was `breeze-dark`)
- **LookAndFeelPackage**: `Scratchy` (not in original)
- **ScaleFactor**: `1.4375` for HDMI-A-2 (not in original)
- **KFileDialog**: 
  - Show hidden files: `true`
  - Show Speedbar: `false`
  - Breadcrumb Navigation: `false`
- **Terminal**: `wezterm`

#### Original values documentation

All original end-4 MaterialYouDark values preserved in comments for easy rollback:
```ini
# ORIGINAL end-4 MaterialYouDark values (commented for easy rollback):
# [Colors:Button]
# BackgroundAlternate=28,27,34
# BackgroundNormal=28,27,34
# ...
```

**Rationale**:
- Unified Catppuccin Macchiato theme across all applications (KDE + GTK + terminal)
- Preserve user's personal settings (icons, scale, Look and Feel)
- Easy rollback to original end-4 theme

**Impact**:
- KDE applications use Catppuccin Macchiato
- Consistency with GTK theme and terminal
- Look and Feel "Scratchy" integration preserved

---

### 6. Add nwg-displays and Catppuccin cursor

**Commit**: `59195c23` (25 Dec 2025)

**Modified files**:
- `sdata/dist-arch/illogical-impulse-hyprland/PKGBUILD`
- `dots/.config/hypr/hyprland/execs.conf`
- `dots/.config/fuzzel/fuzzel.ini`

**Description**:

#### 1. Added nwg-displays package

In `PKGBUILD` added dependency:
```bash
depends=(
  ...
  nwg-displays
)
```

**What is nwg-displays**:
- GUI tool for monitor configuration in Wayland
- Generates `monitors.conf` and `workspaces.conf` for Hyprland
- Repository: https://github.com/nwg-piotr/nwg-displays

#### 2. Catppuccin cursor

In `execs.conf` changed cursor:
```bash
# Before:
exec-once = hyprctl setcursor Bibata-Modern-Classic 24

# After:
exec-once = hyprctl setcursor Catppuccin-Macchiato-Lavender-Cursors 24
```

#### 3. Terminal in fuzzel

In `fuzzel.ini` changed terminal:
```ini
# Before:
terminal=kitty -1

# After:
terminal=wezterm
```

**Rationale**:
- nwg-displays simplifies monitor setup (alternative to manual config editing)
- Catppuccin cursor for theme unity
- Terminal consistency across all launchers

**Impact**:
- GUI available for monitor configuration (launch via menu/command)
- Cursor matches Catppuccin Macchiato theme
- Fuzzel launches WezTerm for terminal commands

---

### 7. WezTerm matugen color template

**Commit**: `5769d682` (25 Dec 2025)

**Modified files**:
- `dots/.config/matugen/templates/wezterm/colors.toml` (new file)
- `dots/.config/matugen/config.toml`

**Description**:

#### Created new template

File `dots/.config/matugen/templates/wezterm/colors.toml` contains Material You color mappings for WezTerm:

```toml
[colors]
foreground = "{{colors.on_surface.default.hex}}"
background = "{{colors.surface.default.hex}}"
cursor_bg = "{{colors.primary.default.hex}}"
cursor_border = "{{colors.primary.default.hex}}"
selection_bg = "{{colors.secondary_container.default.hex}}"
selection_fg = "{{colors.on_secondary_container.default.hex}}"

# ANSI colors (0-7)
ansi = [
  # ... 16 ANSI color mappings
]

# Tab bar
[colors.tab_bar]
background = "{{colors.surface.default.hex}}"
# ... remaining colors
```

#### Updated config.toml

Added WezTerm section:
```toml
[templates.wezterm]
input_path = "~/.config/matugen/templates/wezterm/colors.toml"
output_path = "~/.config/wezterm/colors.toml"
```

#### What matugen does

1. Analyzes wallpaper (`swww` / `hyprpaper`)
2. Generates Material You palette
3. Applies `wezterm/colors.toml` template
4. Saves result to `~/.config/wezterm/colors.toml`

#### WezTerm integration

User needs to add to `~/.config/wezterm/wezterm.lua`:
```lua
-- Load Material You colors from matugen
local colors_file = io.open(os.getenv("HOME") .. "/.config/wezterm/colors.toml", "r")
if colors_file then
  colors_file:close()
  local colors = require("colors")  -- or use TOML parser
  config.colors = colors.colors
end
```

**Rationale**:
- Automatic terminal color sync with wallpaper
- WezTerm integration into Material You ecosystem (end-4 config)
- Dynamic colors instead of static theme

**Impact**:
- WezTerm receives colors from Material You palette
- Colors auto-update when wallpaper changes (if matugen running)
- User must configure `colors.toml` import in `wezterm.lua`

---

### 8. Custom autostart apps and keybinds

**Commit**: `74fdbcaa` (26 Dec 2025)

**Modified files**:
- `dots/.config/hypr/custom/execs.conf`
- `dots/.config/hypr/custom/keybinds.conf`

**Description**:

#### Autostart Applications

Added to `custom/execs.conf`:

| Application | Command | Notes |
|-------------|---------|-------|
| Nextcloud | `sleep 10 && /usr/bin/nextcloud --background` | Cloud sync, 10s delay for network |
| WhisperVoiceInput | `/home/vladimir/Desktop/WhisperVoiceInput` | Voice input tool |
| JetBrains Toolbox | `sleep 5 && /home/vladimir/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox --minimize` | Dev tools, 5s delay for panel |
| Remmina | `remmina -i` | Remote desktop system tray |

**Notes**:
- EasyEffects configured in main `execs.conf`
- LgTvControl runs via systemd (no exec needed)

#### Custom Keybinds

Added to `custom/keybinds.conf`:

**Audio Output Switching**:
- `Ctrl+Alt+Shift+F2`: Switch to YET T10 speakers
- `Ctrl+Alt+Shift+F3`: Switch to Corsair Virtuoso headset
- `Ctrl+Alt+Shift+F4`: Switch to HDMI stereo (TV)

**TV Brightness Control**:
- `Ctrl+Shift+F5`: Increase TV brightness
- `Ctrl+Shift+F6`: Decrease TV brightness

**Desk & Monitor Control**:
- `Ctrl+Shift+F1`: Set desk to sitting position
- `Ctrl+Shift+F2`: Set desk to standing position
- `Ctrl+Shift+F3`: Toggle monitor on/off
- `Ctrl+Shift+F4`: Toggle left monitor mode

**Voice & Transcription**:
- `Ctrl+Alt+Shift+F12`: Toggle voice transcription

**Obsidian Integration**:
- `Ctrl+Shift+F1`: Paste current Obsidian daily note (mapped from Numpad 9 via Kanata)

**Scripts Location**: `~/scripts/`

**Rationale**:
- Files placed in `custom/` directory - copied once during installation, not overwritten on updates
- Allows iterative testing: modify custom/, test, then move to main fork files when stable
- User workflow: custom/ → test → fork main files → commit → deploy

**Impact**:
- Custom autostart apps launch on Hyprland startup
- Custom keybinds available but won't conflict with upstream updates
- Easy to test and modify without affecting main fork configuration

---

### 9. Add documentation for fork customizations

**Commit**: `112983d8` (26 Dec 2025)

**Modified files**:
- `CUSTOMIZATIONS.md` (NEW)

**Description**:

Created comprehensive English documentation for all fork customizations.

**Contents**:
- Overview of fork philosophy and key changes
- Detailed changelog for each of the 8 previous commits
- Integration guide for upstream synchronization
- Rollback instructions for reverting changes

**File Location**: `~/.config/end4_dotfiles/CUSTOMIZATIONS.md`

**Rationale**:
- Maintain clear record of all customizations
- Enable easy review before pulling upstream updates
- Provide reference for similar customizations
- Document workflow for iterative development

**Impact**:
- Clear separation between upstream and personal customizations
- Easy onboarding for future self when returning to project
- Simplified troubleshooting with documented changes

---

### 10. Keyboard layouts and KDE Connect clipboard sync

**Date**: 26 Dec 2025

**Modified files**:
- `dots/.config/hypr/custom/keyboard.conf` (NEW)
- `dots/.config/hypr/custom/execs.conf` (UPDATED)
- `dots/.config/hypr/hyprland.conf` (UPDATED - added source)
- `dots/.local/bin/clipsync` (NEW, executable)
- `dots/.local/bin/kdeconnect-clipboard-watch` (NEW, executable)

**Description**:

#### Keyboard Layouts Configuration

Added US + RU layout switching via `custom/keyboard.conf`:

**Layout settings**:
- Layouts: `us,ru`
- Primary switch: **Caps Lock** (`grp:caps_toggle`)
- Secondary switch: **Insert** key (keyboard-agnostic, works for all keyboards)

**Keyboard repeat**:
- Rate: 50
- Delay: 300

**Requirements**:
- Package: `jq` (for Insert key script)

**Insert key implementation**:
```bash
bind = , Insert, exec, for kbd in $(hyprctl devices -j | jq -r '.keyboards[].name'); do hyprctl switchxkblayout $kbd next; done
```

#### KDE Connect Clipboard Sync (Hyprland only)

Created two scripts with **Hyprland-only guards** to prevent breaking KDE Plasma:

**1. clipsync** (`~/.local/bin/clipsync`):
- Two-way clipboard sync: XWayland ↔ Wayland
- Prevents clipboard issues between Firefox (XWayland) and VS Code (Wayland)
- Guard: `if [ "$XDG_CURRENT_DESKTOP" != "Hyprland" ]; then exit 0; fi`

**2. kdeconnect-clipboard-watch** (`~/.local/bin/kdeconnect-clipboard-watch`):
- Auto-send PC clipboard → Phone (Galaxy S23 Ultra)
- Device ID: `e99eac7b_2902_47fa_944f_b2a564dcc5e3`
- Watches Wayland clipboard with `wl-paste --watch`
- Guard: `if [ "$XDG_CURRENT_DESKTOP" != "Hyprland" ]; then exit 0; fi`

**Autostart configuration**:
Added to `custom/execs.conf`:
```bash
exec-once = ~/.local/bin/clipsync watch
exec-once = ~/.local/bin/kdeconnect-clipboard-watch
```

**What works**:
- ✅ PC → Phone: automatic clipboard sync
- ✅ Phone → PC: use "Send clipboard" on phone
- ✅ XWayland ↔ Wayland: seamless copy-paste between different app types
- ✅ KDE Plasma: scripts exit immediately, don't interfere

**Rationale**:
- Keyboard layouts match current KDE configuration (Caps Lock + Insert)
- KDE Connect clipboard sync essential for mobile workflow
- Hyprland-only guards prevent breaking existing KDE setup
- Scripts in custom/ for easy testing and modification

**Impact**:
- Keyboard layouts ready to use immediately after Hyprland installation
- Clipboard sync between Wayland/XWayland apps works automatically
- Phone integration works same as in KDE
- No risk of breaking KDE Plasma clipboard functionality

---

### 11. Add Catppuccin themes (GTK and cursors)

**Date**: 26 Dec 2025

**Added files**:
- `dots/.themes/Catppuccin-Macchiato-Standard-Lavender-Dark/` (~2.8MB)
- `dots/.themes/Catppuccin-Macchiato-Standard-Lavender-Dark-hdpi/` (~228KB)
- `dots/.themes/Catppuccin-Macchiato-Standard-Lavender-Dark-xhdpi/` (~228KB)
- `dots/.icons/Catppuccin-Macchiato-Lavender-Cursors/` (~6.5MB)

**Total size**: ~10MB

**Description**:

Added Catppuccin Macchiato themes to fork for easy deployment across devices.

**What's included**:
- ✅ GTK themes (3 variants: standard, hdpi, xhdpi)
- ✅ Cursor theme (Catppuccin-Macchiato-Lavender-Cursors)

**What's NOT included** (due to size):
- ❌ Icon theme `Catppuccin-Macchiato` (~161MB)
  - **Download from**: https://github.com/catppuccin/gtk
  - Install to: `~/.icons/Catppuccin-Macchiato/`
  - Or via package manager: `yay -S catppuccin-gtk-theme-macchiato catppuccin-cursors-macchiato`

**Installation**:
Themes in `dots/.themes/` and `dots/.icons/` are automatically copied during `./setup install`.

**Manual installation** (if needed):
```bash
# GTK themes
cp -r dots/.themes/* ~/.themes/

# Cursors
cp -r dots/.icons/* ~/.icons/

# Icon theme (manual download required)
# Download from https://github.com/catppuccin/gtk/releases
# Extract to ~/.icons/Catppuccin-Macchiato/
```

**Rationale**:
- Having themes in fork ensures consistent look across all devices
- Small themes (GTK, cursors) included for convenience (~10MB)
- Large icon theme excluded to keep repository lightweight
- Icons easy to install separately from official source

**Impact**:
- GTK apps use Catppuccin Macchiato theme immediately
- Cursor theme available without manual download
- Icon theme needs one-time manual installation
- Consistent theming between KDE and Hyprland

---

### 12. Remove unused configs (kitty, foot, fish)

**Date**: 27 Dec 2025

**Removed files**:
- `dots/.config/kitty/` (entire directory with all configs)
- `dots/.config/foot/` (entire directory with foot.ini)
- `dots/.config/fish/` (entire directory with fish configs)

**Modified files**:
- `dots/.config/hypr/custom/keybinds.conf` - removed foot from terminal fallbacks
- `dots/.config/quickshell/ii/services/LauncherSearch.qml` - replaced fish with bash
- `sdata/subcmd-install/3.files-exp.yaml` - removed kitty/foot/fish installation sections
- `sdata/subcmd-install/3.files-exp.sh` - set wezterm/zsh as defaults
- `sdata/dist-nix/home-manager/home.nix` - removed foot, replaced fish with zsh
- `sdata/dist-nix/install-deps.sh` - replaced fish with zsh in test commands
- `sdata/dist-fedora/README.md` - replaced fish commands with wezterm
- `sdata/dist-gentoo/useflags` - removed fish, kitty, and eza useflags
- `sdata/dist-gentoo/illogical-impulse-fonts-themes/*.ebuild` - removed fish, kitty, and eza dependencies
- `sdata/dist-gentoo/README.md` - changed code blocks from fish to bash
- `sdata/dist-fedora/feddeps.toml` - removed eza
- `sdata/dist-nix/home-manager/home.nix` - removed foot, eza, replaced fish with zsh

**Description**:

Cleaned up fork by removing all configurations and references for unused programs: kitty, foot, and fish. Since the fork exclusively uses wezterm (terminal) and zsh (shell), keeping unused configs only adds clutter and potential confusion.

**What was cleaned**:
- ❌ **kitty**: All configs removed (replaced with wezterm everywhere)
- ❌ **foot**: All configs removed (not used, wezterm preferred)
- ❌ **fish**: All configs removed (using zsh with oh-my-posh)
- ❌ **eza**: Removed from dependencies (using lsd instead)

**Updated defaults**:
- Terminal selection: wezterm (was: kitty)
- Shell selection: zsh (was: fish)
- Fallback commands: removed kitty/foot/fish from all scripts

**What remains**:
- ✅ wezterm configs (already in fork)
- ✅ zsh configs via `dots/.config/zshrc.d/`
- ✅ Installation scripts only offer wezterm/zsh

**Rationale**:
- Don't want to copy unused configs during installation
- Avoid confusion about which terminal/shell is actually used
- Keep fork clean and focused on actual setup
- Reduce repository size by ~150KB
- Simplify installation scripts (no need to choose what's already decided)
- Already using lsd instead of eza for `ls` replacement

**Impact**:
- Installation process no longer offers kitty/foot/fish
- No unused config files copied to `~/.config/`
- Clear which terminal (wezterm) and shell (zsh) are used
- Easier to maintain fork without dead code

---

## Integration Guide

### Syncing with upstream

When updating from end-4/dots-hyprland `main` branch:

```bash
cd ~/.config/end4_dotfiles
git fetch origin
git merge origin/main
```

### Merge conflicts

If conflicts arise, prioritize **customizations**:
- Terminal: keep `wezterm`, not `kitty`
- Theme: keep `Catppuccin Macchiato`, document new MaterialYouDark values
- OLED protection: keep ddcutil timers

### Post-merge verification

```bash
# Check changes
git diff vladimir-custom origin/main

# Ensure customizations not lost
git log --oneline vladimir-custom --not origin/main
```

---

## Rollback Instructions

### Revert single change

Use `git revert` to undo specific commit:

```bash
# Example: revert WezTerm matugen template
git revert 5769d682

# Example: revert Catppuccin kdeglobals (restore MaterialYouDark)
git revert 4e6b1acc
```

### Full rollback to upstream

To return to original end-4 configuration:

```bash
# Create backup branch
git branch vladimir-custom-backup vladimir-custom

# Hard reset to main
git checkout vladimir-custom
git reset --hard main
```

### Partial rollback (kdeglobals → MaterialYouDark)

Original values preserved in comments in `dots/.config/kdeglobals`:

```bash
# Open file
nano dots/.config/kdeglobals

# Find comments:
# # ORIGINAL end-4 MaterialYouDark values (commented for easy rollback):

# Uncomment needed values and remove Catppuccin versions
```

---

## Contact and Support

- **Fork Author**: Vladimir Rogozhin
- **Email**: vladimirrogozhin90@gmail.com
- **Upstream**: https://github.com/end-4/dots-hyprland
- **Fork**: https://github.com/yourusername/dots-hyprland (specify your repository)

---

_Document created: 2025-12-25_  
_Last updated: 2025-12-26_  
_Version: 1.0_
