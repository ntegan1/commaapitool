#!/bin/bash

is_zsh() { test -n "$ZSH_VERSION";}
is_bash() { ! is_zsh;}

is_bash && \
  test "$0" = "$BASH_SOURCE" && \
  echo please source me instead && \
  exit
is_zsh && whereami="$(cd $(dirname "$0") && pwd)"
is_bash && whereami="$(cd $(dirname "$BASH_SOURCE") && pwd)"

bin_dir="${whereami}/bin"

if echo "$PATH" | grep -q "${bin_dir}"; then
  echo bin_dir already on PATH
else
  echo adding bin_dir to PATH
  export PATH="${PATH}":"${bin_dir}"
fi
