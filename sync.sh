#!/usr/bin/env bash

set -eu

for i in "$@"; do
  case $i in
  -p=* | --plugin-name=*)
    readonly PLUGIN_NAME="${i#*=}"
    shift # past argument=value
    ;;
  -g=* | --git-repo=*)
    readonly GIT_REPO="${i#*=}"
    shift # past argument=value
    ;;
  -u=* | --svn-user=*)
    readonly SVN_USER="${i#*=}"
    shift # past argument=value
    ;;
  -a=* | --assets-dir=*)
    readonly ASSETS_DIR="${i#*=}"
    shift # past argument=value
    ;;
  *)
    echo "Unknown option '${i#*=}', aborting..."
    exit
    ;;
  esac
done

readonly GIT_DIR=$(pwd)/git
readonly GIT_ASSETS_DIR="$GIT_DIR/${ASSETS_DIR:=.wordpress.org}"
#readonly GIT_ASSETS_DIR="$GIT_DIR/assets"
readonly SVN_DIR=$(pwd)/svn
readonly SVN_ASSETS_DIR="$SVN_DIR/assets"
readonly SVN_TAGS_DIR="$SVN_DIR/tags"
readonly SVN_TRUNK_DIR="$SVN_DIR/trunk"
readonly SVN_TRUNK_GIT_DIR="$SVN_DIR/trunk/.git"
readonly SVN_REPO="https://plugins.svn.wordpress.org/$PLUGIN_NAME"

fetch_svn_repo() {
  rm -rf "$SVN_DIR"
  echo "Fetch clean SVN repository."
  if ! svn co "$SVN_REPO" "$SVN_DIR" >/dev/null; then
    echo "Unable to fetch content from SVN repository at URL $SVN_REPO."
    exit
  fi
  echo "done"
}

fetch_git_repo() {
  rm -rf "$GIT_DIR"
  echo "Fetch clean GIT repository."
  git fetch origin master --tags
  if ! git clone "$GIT_REPO" "$GIT_DIR"; then
    echo "Unable to fetch content from GIT repository at URL $GIT_REPO."
    exit
  fi
  echo "Done"
}

stage_and_commit_changes() {
  local message=$1

  #run after sync files
  #svn del --force --quiet "$SVN_TRUNK_GIT_DIR"

  #svn revert --recursive .git

  svn add --force --quiet .
  #svn add --force --quiet .

  #if [ -d "$ASSETS_DIR" ]; then
  #  svn del --force --quiet "$ASSETS_DIR"
  #fi

  png=$(find . -type f -name "*.png")
  if [[ $png ]]; then
    find . -type f -name "*.png" | awk '{print $0 "@"}' | xargs svn propset --quiet --force svn:mime-type image/png
  fi

  jpg=$(find . -type f -name "*.jpg")
  if [[ $jpg ]]; then
    find . -type f -name "*.jpg" | awk '{print $0 "@"}' | xargs svn propset --quiet --force svn:mime-type image/jpeg
  fi

  changes=$(svn status -q)
  if [[ $changes ]]; then
    echo "Detected changes in $(pwd), about to commit them."
    svn commit --username="$SVN_USER" -m "$message"
  else
    echo "No changes detected changes in $(pwd)."
  fi
  echo

}

sync_files() {
  local source=$1/
  local destination=$2/
  local excludeFrom=".git"
  echo "$destination"
  rsync --compress --recursive --delete --delete-excluded --force --archive --exclude "$excludeFrom" "$source" "$destination"

}

sync_tag() {
  local tag=$1
  local message=$1

  #rm -rf "$GIT_DIR/.git/"
  #rm -rf "$SVN_DIR/.git/"
  #rm -rf "$SVN_DIR/tags/.git"
  #rm -rf "$SVN_DIR/tags/v5.3.4/.git"

  #rm -rf "$SVN_DIR/tags/v5.3.4/.git"
  #rm -rf "$SVN_DIR/trunk/.git"
  #rm -rf "$GIT_DIR/vendor"
  #rm -rf "$GIT_DIR/.git/"
  #rm -rf "$SVN_DIR/trung/composer.phar"
  ### IF VENDORS NOT CHANGED - we delete them from uploading ###
  #rm -rf "$GIT_DIR/vendor"
  #rm -rf "$SVN_DIR/tags/$tag/.git"
  ##rm -rf "$SVN_DIR/trunk/vendor"
  ### ENDIF ###

  #echo 'remove tag 0.1'
  #svn del --force "$SVN_DIR/tags/0.1/.git"
  #rm -rf "$SVN_DIR/tags/0.1"

  #svn rm "$SVN_REPO/tags/1.0"

  #svn rm -m 'remove tag' "$SVN_REPO/tags/1.9.6"
  #//TODO KEEP ONLY 5 LAST TAGS
  #svn rm -m 'remove tag' "$SVN_REPO/tags/1.9.5"
  #svn rm -m 'remove tag 1.9.8' "$SVN_REPO/tags/1.9.8"

svn rm -m 'remove tag 1.0.1' "$SVN_REPO/tags/1.0.1"
svn rm -m 'remove tag v5.5.1' "$SVN_REPO/tags/v5.5.1"
svn rm -m 'remove tag v5.5.2' "$SVN_REPO/tags/v5.5.2"
svn rm -m 'remove tag v5.5.3' "$SVN_REPO/tags/v5.5.3"


  #svn commit --username="omykhailenko" -m "Remove old tags"

  #svn del "https://plugins.svn.wordpress.org/mailjet-for-wordpress/trunk/src/widget/css/bootstrap.css"
  #svn del "https://plugins.svn.wordpress.org/mailjet-for-wordpress/trunk/composer.phar"
  if [ -d "$SVN_DIR/tags/$tag" ]; then
    echo "Remove .git from tag dir"
    echo "$SVN_REPO"
    echo "$tag"
    #rm -rf "$GIT_DIR/.git/"
    #rm -rf "$SVN_DIR/.git/"
    #rm -rf "$SVN_DIR/trunk/README.txt"
    #rm -rf "$SVN_DIR/tags/$tag/.git"
    # Tag is already part of the SVN repository, stop here.
    #svn del --force-log "$SVN_DIR/tags/$tag/.git"
    #svn del --force "$SVN_DIR/tags/$tag/.git"
    #svn rm svn-commit.10.tmp
    #svn del "https://plugins.svn.wordpress.org/mailjet-for-wordpress/trunk/README.txt"
    #svn del "https://plugins.svn.wordpress.org/mailjet-for-wordpress/trunk/src/widget/css/bootstrap.css"
    #svn rm "$SVN_REPO/tags/$tag"
    #svn commit --username="$SVN_USER" -m "Remove readme dir"
    echo "Tag already exists."
    #return
  fi

  echo "HERE";
  cd "$GIT_DIR" || exit

  #git pull origin master --tags

  echo "$GIT_DIR"
  echo "Checking out 'tags/$tag'."
  echo "tag - $tag"
  #git checkout "tags/$tag" >/dev/null 2>&1
  #git fetch --all --tags
  #git fetch --tags
  #git remote -v
  #echo "$GIT_REPO"

  git checkout "tags/$tag"

  echo "Copying files over to svn repository in folder $SVN_DIR/tags/$tag."

  echo "DIR=$(pwd)"
  #ls -la
  ##svn changelist --remove --depth infinity .git
  #svn propset svn:ignore '.git/' .
  #svn propset svn:ignore .git .
  sync_files . "$SVN_DIR/tags/$tag"

  cd "$SVN_DIR/tags/$tag" || exit
  stage_and_commit_changes "Release tag $tag"
}

sync_all_tags() {
  cd "$GIT_DIR" || exit
  sync_tag "v6.0.1" #Mailejt
  #sync_tag "1.9.9" #Mailgun
}

sync_trunk() {
  cd "$GIT_DIR" || exit

  echo "Checking out master branch."
  git checkout master >/dev/null 2>&1

  echo "Copying files over to svn repository in folder $SVN_TRUNK_DIR."
  sync_files . "$SVN_TRUNK_DIR"

  cd "$SVN_TRUNK_DIR" || exit
  stage_and_commit_changes "Updating trunk"
}

sync_assets() {
  cd "$GIT_DIR" || exit
  git checkout master >/dev/null 2>&1

  echo "ASSETS SYNC"
  echo "$GIT_ASSETS_DIR"

  if [ -d "$GIT_ASSETS_DIR" ]; then
    sync_files "$GIT_ASSETS_DIR" "$SVN_ASSETS_DIR"
  fi

  cd "$SVN_ASSETS_DIR" || exit

  stage_and_commit_changes "Updating assets"
}

fetch_svn_repo
fetch_git_repo
sync_assets
sync_all_tags
#sync_trunk

exit 0
