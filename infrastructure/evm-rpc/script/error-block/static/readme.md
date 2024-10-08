This is the Imola version, with a range of 29,283,365 to 32,744,115. EVM encountered incorrect event data.

```bash
tar -czvf logs.tar.gz logs.txt
xz -9 logs.tar.gz
split -b 80M logs.tar.gz.xz logs.tar.gz.xz_part_

xz -d  logs.tar.gz.xz
tar -xzvf logs.tar.gz

cd ../../
node --max-old-space-size=8192 src/app_logs.js
```