#! /bin/bash

# Run this from the root of your lesson repository.
# script/lesson-export.sh

# This will create an archive of the docroot/ directory for every branch in
# ./downloads. It will also ensure that each one has the sites/default/files
# and sites/default/files/.htaccess files that are required, and the .gitinore
# removed.
# See: https://github.com/DrupalizeMe/dmesite/wiki/Demo-materials-policy

# Create a place to store all our downloads.
mkdir -p './downloads';

# Make sure we have all the remote branches.
for remote in `git branch -r `; do
  git co --track $remote;
done

git fetch --all
git pull --all

for branch in $(git for-each-ref --format='%(refname)' refs/heads/); do
  file=`echo $branch | sed 's@refs/heads/@@'`
  echo "Exporting $file";
  mkdir -p ./downloads/$file;
  git archive $branch:docroot | tar -x -C ./downloads/$file;

  # Remove the .gitignore file.
  rm ./downloads/$file/.gitignore;

  # Create the files directory and the necessary .htaccess file.
  mkdir -p ./downloads/$file/sites/default/files;
  echo -e "SetHandler Drupal_Security_Do_Not_Remove_See_SA_2006_006\nDeny from all\nOptions None\nOptions +FollowSymLinks" > ./downloads/$file/sites/default/files/.htaccess;

  # Zip it all up. Zip likes to operate in your current working directory and
  # will create un-necessary hierarchy so we push into ./downloads and then pop
  # out when we're done.
  pushd ./downloads
  zip -r ./$file.zip ./$file/*;
  rm -r ./$file;
  popd
done

echo "Done!";
