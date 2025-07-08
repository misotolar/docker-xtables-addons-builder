#!/bin/bash

dpkg-buildpackage -us -uc -b

/bin/cp -av /usr/local/bin/upgrade.sh "$@"
/bin/cp -av /build/*.deb "$@"
