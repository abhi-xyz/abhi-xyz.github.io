#!/usr/bin/env bash
rm -r docs
sleep 1
cp -r public docs
sleep 1
git add
sleep 1
git commit -m "Refactoring"
sleep 1
git push
