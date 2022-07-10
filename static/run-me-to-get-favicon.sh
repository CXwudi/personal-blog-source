# !/bin/bash

# you need nodejs and `npm install -g cli-real-favicon`

# the faviconDescription.json is our hardcoded json getten after you created your favicon on website https://realfavicongenerator.net/
# on the result page, you click the node CLI option to see your own hardcoded json
# the master image is the link to my github avatar, which is gravatar
real-favicon generate faviconDescription.json faviconData.json .