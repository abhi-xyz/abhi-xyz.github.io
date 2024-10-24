deploy:
  hugo
  git add -A
  git commit -m "Refactoring"
  git status
  git push


build:
  hugo

pserve:
  python3 -m http.server -d out 8000
