
if [ $TRAVIS ]
  then
    istanbul --hook-run-in-context cover bin/spectacular -- --coffee --profile specs/**/*.coffee && (cat coverage/lcov.info | node_modules/.bin/coveralls) > /dev/null 2>&1 && (echo "\nPhantomJS\n") && cake phantomjs
else
  cake compile
  if [ $COVERAGE ]
    then
      istanbul --hook-run-in-context cover bin/spectacular bin/spectacular -- --coffee --profile specs/**/*.coffee
  else
      bin/spectacular bin/spectacular --coffee --profile specs/**/*.coffee
  fi

fi
