#!/bin/sh
# Smoke test run by mithro/apt-repo-action's install test, as root in a
# clean container of the suite, after the built packages are installed.
set -eu

# The module is where trixie's libsoapysdr0.8 looks for modules, and every
# library it links against resolved from what the install pulled in. This
# runs before anything else is installed, so it tests what a user gets.
module=$(echo /usr/lib/*/SoapySDR/modules0.8/libPlutoSDRSupport.so)
test -f "$module"
ldd "$module" > /tmp/ldd.txt
cat /tmp/ldd.txt
if grep -q 'not found' /tmp/ldd.txt; then
  echo "$module has unresolved libraries" >&2
  exit 1
fi

# SoapySDR itself loads the module and registers the "plutosdr" driver.
# SoapySDRUtil is Debian's soapysdr-tools, installed only after the check
# above.
apt-get install -y --no-install-recommends soapysdr-tools
if ! SoapySDRUtil --check=plutosdr > /tmp/check.txt 2>&1; then
  cat /tmp/check.txt >&2
  echo "SoapySDR did not register the plutosdr driver" >&2
  exit 1
fi
cat /tmp/check.txt

echo "install test passed"
