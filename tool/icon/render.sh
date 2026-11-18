#!/bin/sh
# Renders fire.svg and fire_maskable.svg into the favicon of the landing page
# and the favicon and icons of every presentation, with headless Chrome.
set -eu

cd "$(dirname "$0")/../.."
chrome=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}

page=$(mktemp -d)
trap 'rm -rf "$page"' EXIT

# Chrome has a minimum window width, so the image is pinned to the top left
# corner of a page instead of being scaled to the window.
render() {
  printf '<body style="margin:0"><img src="file://%s" width="%s" height="%s">' \
    "$PWD/$1" "$2" "$2" > "$page/index.html"
  "$chrome" --headless --disable-gpu --hide-scrollbars \
    --default-background-color=00000000 --allow-file-access-from-files \
    --window-size="$2,$2" --screenshot="$3" "file://$page/index.html" 2>/dev/null
}

cp tool/icon/fire.svg favicon.svg
render tool/icon/fire.svg 64 favicon.png

for web in */web; do
  cp tool/icon/fire.svg "$web/favicon.svg"
  render tool/icon/fire.svg 64 "$web/favicon.png"
  for size in 192 512; do
    render tool/icon/fire.svg "$size" "$web/icons/Icon-$size.png"
    render tool/icon/fire_maskable.svg "$size" "$web/icons/Icon-maskable-$size.png"
  done
done
