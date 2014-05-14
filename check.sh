#!/usr/bin/env bash

VERSIONS_FILE='versions.csv'
TMP_VERSIONS_FILE='/tmp/newversions.tmp'
PLUGIN_DIR='plugins'
PROWL_API_KEY='<Your Prowl API key here>'

function inform_user () {
	local name=$1
	local version=$2
	curl -s -d "apikey=$PROWL_API_KEY&application=New Version&event=$name has new version: $version" https://api.prowlapp.com/publicapi/add > /dev/null
}

for plugin in $PLUGIN_DIR/*.nvplugin; do

	name=$(basename $plugin | rev | cut -c 10- | rev)
	version=$($plugin)

	if [[ -e "$VERSIONS_FILE" ]]; then
		oldversion=$(grep "^$name," "$VERSIONS_FILE" | cut -d ',' -f 2 | head -n1 )
		if [[ -z $oldversion ]]; then
			echo "$name,$version" >> "$VERSIONS_FILE"
		elif [[ $oldversion != $version ]]; then
			grep -v "^$name," "$VERSIONS_FILE" > "$TMP_VERSIONS_FILE"
			echo "$name,$version" >> "$TMP_VERSIONS_FILE"
			mv "$TMP_VERSIONS_FILE" "$VERSIONS_FILE"
			inform_user $name $version
		fi
	else
		echo "$name,$version" > "$VERSIONS_FILE"
	fi

done
