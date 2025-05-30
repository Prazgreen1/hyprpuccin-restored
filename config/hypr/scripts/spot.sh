#!/bin/bash

set -euo pipefail

THEME="catppuccin"
LIGHT="latte"
DARK="frappe"

LOCKFILE="/tmp/spicetify_theme_toggle.lock"

cleanup() {
  rm -f "$LOCKFILE"
}
trap cleanup EXIT INT TERM

if [[ -e "$LOCKFILE" ]]; then
  echo "Lockfile existe: outro processo em execução ou travou." >&2
  exit 1
fi
touch "$LOCKFILE"

CURRENT_SCHEME=$(spicetify config color_scheme | cut -d ' ' -f2)
NEW_SCHEME=$([[ "$CURRENT_SCHEME" == "$LIGHT" ]] && echo "$DARK" || echo "$LIGHT")

spicetify config current_theme "$THEME"
spicetify config color_scheme "$NEW_SCHEME"
spicetify config inject_css 1 inject_theme_js 1 replace_colors 1 overwrite_assets 1
spicetify apply

flatpak run com.spotify.Client &

notify-send -t 3000 -i spotify "🎨 Spicetify" "Theme: $NEW_SCHEME"
