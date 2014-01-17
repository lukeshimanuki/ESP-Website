#!/bin/bash -e

# This script will install or update the dependencies for this website install.
# It reads the list of required Ubuntu packages from packages_base.txt
# (and optionally packages_prod.txt) and the list of required PyPI
# packages from requirements.txt and installs any that are missing. It
# also runs packages_base_manual_install.sh to install any missing
# packages that require manual install. You should run this whenever either of
# those files changes.
#
# The script will automatically detect whether a virtualenv is present
# (see comments in make_virtualenv.sh) and activate it accordingly.

# Parse options
OPTSETTINGS=`getopt -o 'p' -l 'prod' -- "$@"`

eval set -- "$OPTSETTINGS"

while [ ! -z "$1" ]
do
  case "$1" in
    -p) MODE_PROD=true;;
    --prod) MODE_PROD=true;;
     *) break;;
  esac

  shift
done

BASEDIR=$(dirname $(dirname $(readlink -e $0)))

sudo apt-get install -y $(<"$BASEDIR/esp/packages_base.txt")
$BASEDIR/esp/packages_base_manual_install.sh
if [[ "$MODE_PROD" ]]
then
    sudo apt-get install -y $(<"$BASEDIR/esp/packages_prod.txt")
fi

if [[ ! -f "$BASEDIR/env/bin/activate" ]]
then
    $BASEDIR/esp/make_virtualenv.sh
else
    source "$BASEDIR/env/bin/activate"
    pip install -r "$BASEDIR/esp/requirements.txt"
fi

