#!/usr/bin/env bash

VERSIONS_FILE='versions.csv'
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

if [[ -e $VERSIONS_FILE ]]; then
	versions=$(< $VERSIONS_FILE)
fi

for plugin in $PLUGIN_DIR/*.nvplugin; do

	name=$(basename $plugin | rev | cut -c 10- | rev)
	version=$($plugin)

	if [[ -z "$version" ]]; then
		continue
	fi

	if [[ -z "$versions" ]]; then
		versions="$name,$version"
	else
		oldversion=$(echo "$versions" | grep "^$name," | cut -d ',' -f 2- | head -n1 )

		if [[ $oldversion == $version ]];then
			continue
		fi

		versions=$(echo "$versions" | grep -v "^$name,")
		versions=$(echo -e "$versions\n$name,$version")

		if [[ -n $oldversion ]] && [[ $oldversion != $version ]]; then
			inform_user $name $version
		fi
	fi

done

echo -e "$versions" > "$VERSIONS_FILE"