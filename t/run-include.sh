#!/bin/sh

if [ `whoami` != "root" ]; then
	echo "Must be run as root, restarting (sudo $0)"
	sudo "$0" "$@"
	exit $?
fi

pgrep keyd && { echo "Stop keyd before running tests"; exit -1; }

tmpdir=$(mktemp -d)

cleanup() {
	rm -rf "$tmpdir"
	kill $pid

	trap - EXIT
	exit
}

trap cleanup INT

cd "$(dirname "$0")"
cp include-base.conf "$tmpdir"
cp include-specific.conf "$tmpdir"
cp include-specific.conf "$tmpdir/test.conf"

(cd ..;make CONFIG_DIR="$tmpdir") || exit -1
../bin/keyd > test.log 2>&1 &

pid=$!

sleep .7s
echo "include.t" | sed 's/^/t\//' > /dev/null
test_files="include.t"
./runner.py -v $test_files
cleanup