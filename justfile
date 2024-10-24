tmpdir  := `mktemp -d`
version := "0.1.2"
tardir  := tmpdir / "abhinandhs.in-" + version
tarball := tardir + ".tar.gz"

server:
  deno task serve

publish:
  rm -f {{tarball}}
  mkdir {{tardir}}
  cp -r * {{tardir}}
  tar zcvf {{tarball}} {{tardir}}

deploy:
  hugo
  git status
  git add -A
  git commit -m "Refactoring"
  git push

backup:
  hugo --gc
  hugo

build:
  hugo

pserve:
  python3 -m http.server -d out 8000
