#!/bin/bash
echo "Clean-up Previous Source"
rm -r public/

echo "Generate Static Site Source"
hugo --gc

echo "Copy Readme Files"
cp -r README.md README.zh-cn.md public/.

echo "Done"
