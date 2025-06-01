#!/usr/bin/env bash

if [ -n "$@" ]; then
  QUERY="$@"

  if [[ "$@" == /* || "$@" == ~* ]]; then
    # Converter ~ para $HOME, se necessário
    [[ "$@" == ~* ]] && QUERY="${QUERY/#\~/$HOME}"

    if [[ "$@" == *\?\? ]]; then
      PATH_TO_OPEN="${QUERY%\/* \?\?}"
    else
      PATH_TO_OPEN="$QUERY"
    fi

    coproc (exo-open "$PATH_TO_OPEN" >/dev/null 2>&1)
    exec 1>&-
    exit

  elif [[ "$@" == \?\* ]]; then
    find ~ -type d -path '*/\.*' -prune -o -type f -iname "*${QUERY#\?}*" -print |
      sed "s|^$HOME|~|g" | sed 's|$| ??|'

  else
    find ~ -type d -path '*/\.*' -prune -o -type f -iname "*${QUERY#!}*" -print |
      sed "s|^$HOME|~|g"
  fi

else
  exit 0
fi
