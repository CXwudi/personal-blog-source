#!/bin/bash
echo "Clean-up Previous Source"
rm -r public/

echo "Generate Static Site Source (with Draft)"
hugo -D --gc

echo "Copy Readme Files"
cp -r readme\ for\ public/. public/.

echo "Done"
