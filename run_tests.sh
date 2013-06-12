
if [ $TRAVIS ]
  then
    istanbul --hook-run-in-context cover bin/spectacular -- --coffee --profile --documentation -- specs/**/*.coffee && (cat coverage/lcov.info | node_modules/.bin/coveralls) > /dev/null 2>&1 && (echo "\nPhantomJS\n") && cake phantomjs
else
  cake compile
  if [ $COVERAGE ]
    then
      istanbul --hook-run-in-context cover bin/spectacular -- --coffee --profile --documentation specs/**/*.coffee
  else
      bin/spectacular --coffee --profile --documentation specs/**/*.coffee
  fi

fi