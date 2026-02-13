#!/bin/sh
# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# curl -s https://paul-grozav.github.io/boot-config/boot.sh | sh
# curl -s https://paul-grozav.github.io/boot-config/boot.sh | sh -s -- --gui
# ============================================================================ #
set -x &&
iso_file="$(mktemp)" &&

echo "Downloading iso ..." &&
curl \
  --silent \
  --output ${iso_file} \
  https://paul-grozav.github.io/boot-config/ipxe.iso \
  &&

echo "Booting ..." &&
params="-serial stdio" &&
params="${params} -display none" &&
params="${params} -machine graphics=off" &&
if [ "${1}" = "--gui" ]
then
  params=""
fi &&

( qemu-system-x86_64 \
  -m 2G \
  -cdrom ${iso_file} \
  ${params} \
  || true ) &&

rm -f ${iso_file} &&

set +x &&
true
# ============================================================================ #
