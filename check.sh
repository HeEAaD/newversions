#!/usr/bin/env bash

VERSIONS_FILE='versions.csv'
TMP_VERSIONS_FILE='/tmp/newversions.tmp'
PLUGIN_DIR='plugins'
PROWL_API_KEY_FILE='prowl_api_key.conf'

function inform_user () {
	local name=$1
	local version=$2
	curl -s -d "apikey=$PROWL_API_KEY&application=New Version&event=$name has new version: $version" https://api.prowlapp.com/publicapi/add > /dev/null
}

PROWL_API_KEY=$(cat $PROWL_API_KEY_FILE)

if [[ -z "$PROWL_API_KEY" ]] || [[ "$PROWL_API_KEY" == "<Your Prowl API key here>" ]]; then
	echo "Set your Prowl API key in $PROWL_API_KEY_FILE."
	exit 1
fi

for plugin in $PLUGIN_DIR/*.nvplugin; do

	name=$(basename $plugin | rev | cut -c 10- | rev)
	version=$($plugin)

	if [[ -z "$version" ]]; then
		continue
	fi

	if [[ -e "$VERSIONS_FILE" ]]; then
		oldversion=$(grep "^$name," "$VERSIONS_FILE" | cut -d ',' -f 2- | head -n1 )
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
