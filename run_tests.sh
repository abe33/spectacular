#!/bin/sh

if [ $TRAVIS ]
  then
    echo "  Node Tests\n"
    istanbul --hook-run-in-context cover bin/spectacular -- test --verbose 'specs/**/*.coffee'
    node_result=$?

    echo "  Send coverage to coveralls.io\n"
    (cat coverage/lcov.info | node_modules/.bin/coveralls) > /dev/null 2>&1

    echo "  Send coverage to codeclimate.com\n"
    CODECLIMATE_REPO_TOKEN=4b5c44628063dc2a5c65e0169bc3c7accee4b570aed71d9a8599f2654c87c861 codeclimate < coverage/lcov.info 

    echo "  PhantomJS Tests\n"
    bin/spectacular phantomjs 'specs/**/*.coffee'
    phantomjs_result=$?

    echo "  SlimerJS Tests\n"
    bin/spectacular slimerjs --slimerjs-bin bin/slimerjs08/slimerjs 'specs/**/*.coffee'
    slimerjs_result=$?

    exit $node_result + $phantomjs_result + $slimerjs_result
else
  cake compile
  if [ $COVERAGE ]
    then
      istanbul --hook-run-in-context cover bin/spectacular -- test 'specs/**/*.coffee'
      exit $?
  else
      bin/spectacular test 'specs/**/*.coffee'
      exit $?
  fi
fi
