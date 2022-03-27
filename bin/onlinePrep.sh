#!/bin/bash
# shellcheck disable=SC2154,SC2034
# this script contains:
## idempotent functions to define if LibreOffice Online has to be compiled
## Installation of requirements for Libreoffice Online build only
## Download & install LibreOffice Online Sources
cp /usr/local/lib/libPocoCrypto.so.81 /usr/lib/
cp /usr/local/lib/libPocoXML.so.81 /usr/lib/
set -e
SearchGitOpts=''
[ -n "${cool_src_branch}" ] && SearchGitOpts="${SearchGitOpts} -b ${cool_src_branch}"
[ -n "${cool_src_commit}" ] && SearchGitOpts="${SearchGitOpts} -c ${cool_src_commit}"
[ -n "${cool_src_tag}" ] && SearchGitOpts="${SearchGitOpts} -t ${cool_src_tag}"
#### Download dependencies ####
if [ -d ${cool_dir} ]; then
  cd ${cool_dir}
else
  git clone ${cool_src_repo} ${cool_dir}
  cd ${cool_dir}
fi
declare repChanged
eval "$(SearchGitCommit $SearchGitOpts)"
if [ -f ${cool_dir}/coolwsd ] && $repChanged ; then
  cool_forcebuild=true
fi
if [ "${DIST}" = "Debian" ]; then
  if [ "${CODENAME}" = "bullseye" ];then
    apt-get install  node-gyp libssl-dev npm libpococrypto70 -y
  else 
    apt-get install nodejs-dev node-gyp libssl1.0-dev npm libpococrypto50 -y
  fi
else
  apt-get install nodejs-dev node-gyp libssl1.0-dev npm libpococrypto50 -y
fi

set +e
if ! npm -g list jake >/dev/null; then
#  npm install -g npm
  npm install -g jake
fi

sed  '16a\
#include <list>
' < ${cool_dir}/wsd/AdminModel.hpp > ${cool_dir}/wsd/AdminModeltmp.hpp 
cat ${cool_dir}/wsd/AdminModeltmp.hpp > ${cool_dir}/wsd/AdminModel.hpp

