#!/bin/bash

# TODO list:
# 0) Actually add code to perform the dot file installation
# 1) Add options for specifying individual / multiple specific source files to
#    update.
# 2) Add a versioning mechanic to the source files?
# 3) Add the ability to detect new changes and update source?
#    a) Maybe not necessary since the installed dot files will be symlinks?
# 4) Get rid of global variables
# 5) Update .vimrc file to:
#    a) turn snytax highlighting on
#    b) fix auto tab settings (maybe a mac specific issue)
#    c) create 2 space auto tab settings for .sh files
#    d) find tool / function to auto format shell script spacing?

#
# define global variables / settings
#
DEBUG=false
INSTALL_MODE=true
BASEDIR="$(cd $(dirname $0); pwd -P)"
SOURCEDIR="$BASEDIR/source-files"
BACKUPDIR="$BASEDIR/backups"

SOURCEDIR_REL_PATH="$(echo "$SOURCEDIR" | sed "s#^$HOME/##g")"

echo "$SOURCEDIR_REL_PATH"

#
# define logging functions
#
BASE_LOGGER="logger -i -s -t dot-file-installer"

function log_debug () {
  if [ "$DEBUG" == "true" ]; then
    $BASE_LOGGER -p syslog.debug "$*";
  fi
}

function log_info() {
  $BASE_LOGGER -p syslog.info "$*"
}

function log_warn() {
  $BASE_LOGGER -p syslog.warn "$*"
}

function log_error() {
  $BASE_LOGGER -p syslog.error "$*"
}

#
# print usage and version
#
function print_usage() {
  echo $0
}

#
# main function
#
function main() {

  # declare locals
  local source_File_list=""

  # parse options
  while [[ $# -gt 0 ]]; do
    case $1 in
      -d|--debug)
        DEBUG=true
        log_debug "Debug option enabled."
        shift
        ;;
      -h|--help)
        print_usage
        exit 1
        ;;
      -r|--restore|--restore-mode)
        INSTALL_MODE=false
        log_debug "Restore mode option enabled."
        shift
        ;;
      -*)
        log_error "Invalid option '$1' detected."
        print_usage
        exit 2
        ;;
      *)
        log_debug "Explicitly adding '$1' to the source file list"
        if [ -z "$source_file_list" ]; then
          source_file_list="$1"
        else
          source_file_list="$source_file_list $1"
        fi
        shift
        ;;
    esac
  done

  # debug logging
  log_debug "Base Directory: $BASEDIR"
  log_debug "Source Directory: $SOURCEDIR"
  log_debug "Source Directory Relative Path: $SOURCEDIR_REL_PATH"
  log_debug "Backup Directory: $BACKUPDIR"

  # compute the source file list to work with
  if [ "$source_file_list" ]; then
    log_debug "The source file list has been manually configured."
  else
    # if a source list hasn't been specified then assume that all of the dot
    # files in the source directory will be installed / restored
    source_file_list="$(ls -1A "$SOURCEDIR" | tr '\n' ' ')"
    log_debug "Automatically generated the source file list."
  fi
  log_debug "source_file_list: $source_file_list"

  # compute the backup file list
  backup_file_list=""
  for file in "$(ls -1A $SOURCEDIR)"; do
    if [ -e "$file" ]; then
      backup_file_list="$backup_file_list \"$HOME/$file\""
    fi
  done
  log_debug "Backup File List: $backup_file_list"

  # TODO: ignore this line (used to test tar failure). Need to find a more
  # robust way to perform tests
  # backup_file_list="test1111 $backup_file_list"

  backup_file="$BACKUPDIR/dot-file-backup-$(date +%Y-%m-%d_%H%M).tgz"
  log_debug "Backup File: $backup_file"

  if ! [ -d "$BACKUPDIR" ]; then
    log_warn "The default backup directory is missing, environment not sane."
    mkdir "$BACKUPDIR"
  fi

  # if the backup file list is empty, don't backup
  if ! [ "$backup_file_list" ]; then
    log_info "The backup file lsit is empty, skipping backup!"
  else

    # Create backups of existing dot files. This will follow symlinks so that
    # symlinks will be replaced with actual files on restore.
    log_info "Backup up existing configuration files..."
    log_debug "tar -cvzLlf $backup_file $backup_file_list"

    tar_output="$(tar -cvzLlf "$backup_file" $backup_file_list 2>&1)"
    tar_exit_code=$?

    # verify the completion status of the tar command
    if [ $tar_exit_code -eq 0 ]; then
      log_info "Tar backup completed successfully"
    else
      log_error "tar returned a non-zero exit code: $tar_exit_code"
      echo -e "$tar_output" | while read line; do
        log_error " $line"
      done
      exit 3
    fi
  fi

  # install the symlinks to the dot files
  for dot_file in $source_file_list; do
    log_info "Processing dot file: $dot_file"
    rm -rf "$HOME/$dot_file"
    ln -s "$SOURCEDIR_REL_PATH/$dot_file" "$HOME/$dot_file"
  done

}



# is if guard to allow for sourcing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
