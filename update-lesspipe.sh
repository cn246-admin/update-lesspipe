#!/bin/sh

# Description: Download, verify and install lesspipe on Linux and Mac
# Author: Chuck Nemeth
# https://github.com/wofr06/lesspipe

# VARIABLES
bin_dir="$HOME/.local/bin"
cpl_dir="$HOME/.config/zsh/completions/"
man_dir="$HOME/.local/share/man/man1"
src_dir="$HOME/.local/src"

if command -v lesspipe.sh >/dev/null; then
  lesspipe_installed_version=$(awk -F'=' '/lesspipe_version=[0-9]\.[0-9]+/ { print $2 }' "${bin_dir}/lesspipe.sh")
else
  lesspipe_installed_version="Not Installed"
fi

v_lesspipe_version="$(curl -s https://api.github.com/repos/wofr06/lesspipe/releases/latest | \
              awk -F': ' '/tag_name/ { gsub(/\"|\,/,"",$2); print $2 }')"

lesspipe_version="${v_lesspipe_version#?}"

lesspipe_repo="git@github.com:wofr06/lesspipe.git"


# FUNCTIONS
# colored output
code_grn () { tput setaf 2; printf '%s\n' "${1}"; tput sgr0; }
code_red () { tput setaf 1; printf '%s\n' "${1}"; tput sgr0; }
code_yel () { tput setaf 3; printf '%s\n' "${1}"; tput sgr0; }


# PATH CHECK
case :$PATH: in
  *:"${bin_dir}":*)  ;;  # do nothing
  *)
    code_red "[ERROR] ${bin_dir} was not found in \$PATH!"
    code_red "Add ${bin_dir} to PATH or select another directory to install to"
    exit 1
    ;;
esac


# VERSION CHECK
cd "${src_dir}" || exit

if [ "${lesspipe_version}" = "${lesspipe_installed_version}" ]; then
  printf '%s\n' "Installed Verision: ${lesspipe_installed_version}"
  printf '%s\n' "Latest Version: ${lesspipe_version}"
  code_yel "[INFO] Already using latest version. Exiting."
  exit 0
else
  printf '%s\n' "Installed Verision: ${lesspipe_installed_version}"
  printf '%s\n' "Latest Version: ${lesspipe_version}"
fi


# DOWNLOAD
if [ ! -d "${src_dir}/lesspipe" ]; then
  printf '%s\n' "Cloning the lesspipe repo"
  git clone "${lesspipe_repo}" lesspipe
else
  printf '%s\n' "Updating the lesspipe repo"
  cd "${src_dir}/lesspipe" || exit
  git pull
fi


# PREPARE
# Create directories
[ ! -d "${bin_dir}" ] && install -m 0700 -d "${bin_dir}"
[ ! -d "${man_dir}" ] && install -m 0700 -d "${man_dir}"


# INSTALL
# Create symlinks
printf '%s\n' "Creating symlinks"
ln -sf "${src_dir}/lesspipe/lesspipe.sh" "${bin_dir}"
ln -sf "${src_dir}/lesspipe/code2color" "${bin_dir}"
ln -sf "${src_dir}/lesspipe/archive_color" "${bin_dir}"
ln -sf "${src_dir}/lesspipe/vimcolor" "${bin_dir}"
ln -sf "${src_dir}/lesspipe/sxw2txt" "${bin_dir}"
ln -sf "${src_dir}/lesspipe/lesscomplete" "${bin_dir}"
ln -sf "${src_dir}/lesspipe/lesspipe.1" "${man_dir}"
ln -sf "${src_dir}/lesspipe/_less" "${cpl_dir}"


# VERSION CHECK
code_grn "Done!"
code_grn "Installed Version: ${lesspipe_installed_version}"

# vim: ft=sh ts=2 sts=2 sw=2 sr et
