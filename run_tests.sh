#!/bin/sh

if [ $TRAVIS ]
  then
    echo "  Node Tests\n"
    istanbul --hook-run-in-context cover bin/spectacular test -- specs/**/*.coffee
    node_result=$?

    echo "  Send coverage to coveralls.io\n"
    (cat coverage/lcov.info | node_modules/.bin/coveralls) > /dev/null 2>&1

    echo "  PhantomJS Tests\n"
    bin/spectacular phantomjs specs/**/*.coffee
    phantomjs_result=$?

    exit $node_result || $phantomjs_result
else
  cake compile
  if [ $COVERAGE ]
    then
      istanbul --hook-run-in-context cover bin/spectacular -- test specs/**/*.coffee
      exit $?
  else
      bin/spectacular test specs/**/*.coffee
      exit $?
  fi
fi
