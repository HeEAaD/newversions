#!/usr/bin/env bash

VERSIONS_FILE='versions.csv'
TMP_VERSIONS_FILE='/tmp/newversions.tmp'
PLUGIN_DIR='plugins'

function inform_user () {
	local name=$1
	local version=$2
	echo "New Version for $name ($version)."
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


