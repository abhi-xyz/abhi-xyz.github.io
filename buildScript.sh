#!/usr/bin/env fish
rm -r docs
cp -r public docs
git add -A && git c && git push
