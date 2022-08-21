#!/bin/bash
 
if [[ $VERCEL_GIT_COMMIT_REF == "publish"  ]] ; then 
  echo "Building for production"
  ./generate-production.sh
else 
  echo "Building for test"
  ./generate-test.sh
fi