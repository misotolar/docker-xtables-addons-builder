#!/bin/bash

if [[ $UID -ne 0 ]]; then
    /usr/bin/sudo true
fi

CURRENT=$(dirname "$0")
INSTALL=()

for FILENAME in "$CURRENT"/*.deb; do
    PACKAGE="${FILENAME##*/}"
    PACKAGE="${PACKAGE%%_*}"

    /usr/bin/dpkg -l | /bin/grep "$PACKAGE" | /bin/grep -q ii && INSTALL+=("$FILENAME")
done

if [[ -n "${INSTALL[*]}" ]]; then
    /usr/bin/sudo /usr/bin/dpkg -i "${INSTALL[@]}"
fi
