deploy:
  hugo
  git status
  git add -A
  git commit -m "Refactoring"
  git push


build:
  hugo

pserve:
  python3 -m http.server -d out 8000
