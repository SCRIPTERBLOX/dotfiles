#!/usr/bin/env bash

# RSS feed URL — you can change this to any source you like
FEED_URL="https://news.ycombinator.com/rss"

# Fetch, parse, and format output
HEADLINES=$(curl -s "$FEED_URL" \
  | xmllint --xpath "//item/title/text()" - \
  | head -n 5 \
  | jq -R -s -c 'split("\n")[:-1]')

# Output JSON for Waybar
#echo "$(echo ($HEADLINES)[0])"
echo "📰 $(echo $HEADLINES | jq -r '.[0]')"
echo "📰 $(echo $HEADLINES | jq -r '.[1]')"
echo "📰 $(echo $HEADLINES | jq -r '.[2]')"
echo "📰 $(echo $HEADLINES | jq -r '.[3]')"
echo "📰 $(echo $HEADLINES | jq -r '.[4]')"

