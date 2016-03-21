#!/bin/bash
set -e

if [ ! -d $GATK_PATH -o ! -d $NOVOALIGN_PATH ]; then
  if [ -z "$BUNDLE_SECRET" ]; then
    echo "ERROR: GATK and/or Novoalign is missing, but secret key is not set for auto-download."
    exit 1

  else
    echo "Fetching encrypted Novoalign & GATK bundle for Travis"
    pwd
    wget http://www.broadinstitute.org/~dpark/viral_ngs-gatk_novoalign-encrypted_for_travis.tar.gz.enc
    openssl aes-256-cbc -d -k "$BUNDLE_SECRET" -in viral_ngs-gatk_novoalign-encrypted_for_travis.tar.gz.enc -out bin_bundles.tar.gz
    tar -xzpvf bin_bundles.tar.gz -C "$CACHE_DIR"

  fi
fi

# perhaps not needed?
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then 
  echo "Preparing OSX to install tools..."
  export CC=gcc-4.9
  export CXX=g++-4.9
  alias gcc='$(which gcc-4.9)'
  alias g++='$(which g++-4.9)'
  unset NOVOALIGN_PATH
fi

echo "CC: $CC" 
echo "CXX: $CXX" 
echo "which gcc: $(which gcc)" 
echo "gcc --version: $(gcc --version)"
echo "java version: $(java -version 2>&1 | grep 'java version')" 
env

echo "Installing and validating bioinformatic tools"
#nosetests -v test.unit.test_tools.TestToolsInstallation
nosetests -v test.unit.test_tools
