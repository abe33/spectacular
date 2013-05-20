coffee --compile --bare --output lib/ src/

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
