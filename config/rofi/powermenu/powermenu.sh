#!/usr/bin/env bash

# Current Theme
dir="$HOME/.config/rofi/powermenu/"
theme='style'

# Uptime formatado
uptime="$(uptime -p | sed -e 's/up //g' -e 's/hour/hr/g' -e 's/minute/min/g')"

# Opções
shutdown='Shutdown'
reboot='Reboot'
suspend='Suspend'
yes='yes'
no='no'

# Menu Rofi principal
rofi_cmd() {
  rofi -dmenu \
    -p " $USER" \
    -mesg " Uptime: $uptime" \
    -theme "${dir}/${theme}.rasi"
}

# Menu de confirmação
confirm_cmd() {
  rofi -markup-rows -dmenu \
    -p 'Confirmation' \
    -mesg 'Are you Sure?' \
    -theme "${dir}/confirmation.rasi"
}

# Confirmação antes da ação
confirm_exit() {
  echo -e "<span foreground='#a6e3a1'>$yes</span>\n<span foreground='#f38ba8'>$no</span>" | confirm_cmd
}

# Executa rofi com as opções
run_rofi() {
  echo -e "$shutdown\n$reboot\n$suspend" | rofi_cmd
}

# Executa comando com confirmação
run_cmd() {
  selected="$(confirm_exit)"
  if [[ "$selected" =~ "$yes" ]]; then
    case $1 in
    --shutdown) systemctl poweroff ;;
    --reboot) systemctl reboot ;;
    --suspend)
      command -v playerctl &>/dev/null && playerctl pause
      command -v wpctl &>/dev/null && wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
      systemctl suspend
      ;;
    esac
  else
    exit 0
  fi
}

# Execução principal
chosen="$(run_rofi)"
case ${chosen} in
$shutdown) run_cmd --shutdown ;;
$reboot) run_cmd --reboot ;;
$suspend) run_cmd --suspend ;;
esac
