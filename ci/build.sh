# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
set -x &&
script_dir="$( cd $( dirname ${0} ) && pwd )" &&
project_root="$( cd ${script_dir}/.. && pwd )" &&

apk add git perl make gcc libc-dev xz-dev syslinux xorriso &&
pwd && ls -la ${project_root} &&
git clone https://github.com/ipxe/ipxe.git ${project_root}/ipxe &&
pwd && ls -la ${project_root} && ls -la ${project_root}/ipxe &&
ls -la ${project_root}/ipxe/src &&

# nano config/console.h # uncomment CONSOLE_SERIAL if you need it

# Make all (default config)
# make &&

( cat - <<EOF
#!ipxe
echo Starting iPXE embeded script!
ifstat
dhcp
shell
EOF
) > ${project_root}/my_script.ipxe

# See: https://ipxe.org/appnote/buildtargets
# Make .iso
(
  cd ${project_root}/ipxe/src &&
  make \
    DEBUG=dhcp,tftp,http \
    ` # This needs to be a relative path, as defined in Makefile ` \
    bin/ipxe.iso \
    EMBED=${project_root}/my_script.ipxe \
    &&
  true
)

# For HTTPS support:
# apk add openssl openssl-dev &&
# make bin/ipxe.iso TRUST=/etc/ssl/certs/ca-certificates.crt \
#   DEBUG=tls,x509:3,certstore,privkey
# Or with TRUSTing LE's R3:
# curl https://letsencrypt.org/certs/lets-encrypt-r3.pem -o /root/r3.pem
# make bin/ipxe.iso \
#   TRUST=/root/r3.pem DEBUG=tls,x509:3,certstore,privkey
# See also: make bin-x86_64-efi/ipxe.efi -j10 \
#   DEBUG=dhcp,tftp,http EMBED=/mnt/my_script.ipxe
# make bin-x86_64-efi/snponly.efi -j10 \
#   DEBUG=dhcp,tftp,http
# Note that embeding a script in snponly seems to corrupt the initramfs
# However, snponly has support for running autoexec.ipxe that gets
# pulled from the TFTP server that offers the .efi binary.

cp ${project_root}/ipxe/src/bin/ipxe.iso ${project_root}/http/ &&
exit 0
# ============================================================================ #
