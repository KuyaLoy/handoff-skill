#!/bin/sh
# A small static site with no handoff files.
mkdir -p src
printf '# Example Shop\n\nStatic site for example.com. Pages live in src/.\n' > README.md
printf '<!doctype html>\n<html>\n<head>\n<title>Shop</title>\n</head>\n<body>\n<h1>Shop</h1>\n</body>\n</html>\n' \
  > src/index.html
