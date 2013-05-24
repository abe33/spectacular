cake compile

if [ $TRAVIS ]
  then
    istanbul --hook-run-in-context cover bin/spectacular -- --coffee --profile specs/**/*.coffee
else
  bin/spectacular --coffee --profile specs/**/*.coffee
fi
