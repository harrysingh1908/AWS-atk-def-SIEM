#!/bin/bash

docker rm -f juiceshop modsec 2>/dev/null

docker run -d \
  --name juiceshop \
  --restart unless-stopped \
  -p 3000:3000 \
  bkimminich/juice-shop

sleep 10

docker run -d \
  --name modsec \
  --restart unless-stopped \
  --network host \
  -e BACKEND=http://127.0.0.1:3000 \
  -e MODSEC_RULE_ENGINE=On \
  -e PARANOIA=2 \
  owasp/modsecurity-crs:nginx

echo "Pipeline 1 active on port 8080"
