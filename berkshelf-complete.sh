#!/bin/bash
#
# Description
#   Add tab completion for berkshelf
#
# Configuration:
#   BERKSHELF_BERKSFILE (default is 'Berksfile')
#
# Notes:
#   Must be added to your ~/.bashrc, ~/.zshrc, etc
#
# Author:
#   Seth Vargo <sethvargo@gmail.com>
#
# License:
#   Apache 2.0
#

_bundler() {
  which bundle > /dev/null 2>&1 && [ -f "$(pwd)/Gemfile" ]
}

# Overwrite berks to use bundler if defined
_berks() {
  [ _bundler ] && bundle exec berks $@ || berks $@
}

_berkshelf_commands() {
  local cachefile=~/.berkshelf/.commands
  [ ! -f $cachefile ] && $(_berks help | grep berks | cut -d " " -f 4 > $cachefile)
  cat $cachefile
}

_berkshelf_cookbooks() {
  [ -z $BERKSHELF_BERKSFILE ] && BERKSHELF_BERKSFILE="Berksfile"
  cat $BERKSHELF_BERKSFILE | grep "cookbook" | cut -d "'" -f 2
}

_local_cookbooks() {
  ls -d cookbooks/*/ | cut -d "/" -f 2
}

_berkshelf() {
  # local curr prev commands
  COMPREPLY=()
  curr="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # List of commands to complete
  commands=`_berkshelf_commands`

  case "${prev}" in
    "open"|"outdated"|"show"|"update"|"upload")
      local berkshelf_cookbooks=`_berkshelf_cookbooks`
      local local_cookbooks=`_local_cookbooks`
      local cookbooks=`echo $berkshelf_cookbooks $local_cookbooks | sort -n | uniq`
      COMPREPLY=($(compgen -W "${cookbooks}" -- ${curr}))
      return 0
      ;;
    *)
      ;;
  esac

  COMPREPLY=($(compgen -W "${commands}" -- ${curr}))
  return 0
}

complete -F _berkshelf berks
