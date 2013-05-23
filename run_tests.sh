alias co='coffee --compile --bare --output lib/ '

 co --join lib/spectacular.js src/extensions.coffee  src/bootstrap.coffee src/factories.coffee src/mixins.coffee src/promises.coffee src/examples.coffee src/runner.coffee src/environment.coffee

 co src/cli.coffee src/server.coffee src/index.coffee src/matchers.coffee src/spectacular_bin.coffee src/utils.coffee src/console_reporter.coffee src/browser_reporter.coffee

echo '#!/usr/bin/env node' > bin/spectacular
cat lib/spectacular_bin.js >> bin/spectacular
chmod +x bin/spectacular
rm lib/spectacular_bin.js
if [ $TRAVIS ]
  then
    istanbul --hook-run-in-context cover bin/spectacular -- --coffee --profile specs/**/*.coffee
else
  bin/spectacular --coffee --profile specs/**/*.coffee
fi
