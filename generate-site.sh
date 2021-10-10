#!/bin/bash
echo "Clean-up Previous Source"
rm -r public/

echo "Generate Static Site Source"
hugo

echo "Copy Readme Files"
cp -r readme\ for\ public/. public/.

echo "Done"
