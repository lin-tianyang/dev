#!/bin/bash

date=`date +%F:%H%M`
aws s3 sync  /data/gtcdn/wst/wst-clinet-cdn/ s3://xxx/wst-client-cdn/


aws cloudfront create-invalidation --distribution-id         xxx --paths "/*"
echo "$date wstcdn" >>/usr/local/shell/check/wstclientcdn.txt 
