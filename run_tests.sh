
if [ $TRAVIS ]
  then
    istanbul --hook-run-in-context cover bin/spectacular -- --coffee --profile specs/**/*.coffee && cake phantomjs
else
  cake compile
  bin/spectacular --coffee --profile specs/**/*.coffee
fi
