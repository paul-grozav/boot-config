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
  ` # CPU cores for the machine ` \
  -smp 1 \
  ` # Set RAM memory to 2GiB` \
  -m 2G \
  ` # Mount iso as CD-ROM file` \
  -cdrom ${iso_file} \
  ` # Network interface/card that even MSDOS can support ` \
  ` # -net nic,model=ne2k_isa ` \
  ` # -net user ` \
  ${params} \
  || true ) &&

rm -f ${iso_file} &&

set +x &&
true
# ============================================================================ #
