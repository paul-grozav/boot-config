#!/bin/sh
# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
set -x &&
script_dir="$( cd $( dirname ${0} ) && pwd )" &&
project_root="$( cd ${script_dir}/.. && pwd )" &&

apk add --no-cache \
  ` # git - clone ipxe project ` \
  git \
  ` # perl - required for building ipxe ` \
  perl \
  ` # make - Build system for the ipxe project ` \
  make \
  ` # gcc - Compiler to build the ipxe C code ` \
  gcc \
  ` # libc-dev - Basic standard C library for ipxe ` \
  libc-dev \
  binutils \
  musl-dev \
  mtools \
  ` # get certificate from github ` \
  openssl \
  ca-certificates \
  libressl-dev \
  ` # xz-dev - (Alpine) required by the ipxe project ` \
  xz-dev \
  ` # liblzma-dev - (ubuntu) (and isolinux) required by the ipxe project ` \
  ` # liblzma-dev isolinux ` \
  ` # syslinux - required to make the iso bootable ` \
  syslinux \
  ` # xorriso - to create the iso file ` \
  xorriso \
  &&

git clone https://github.com/ipxe/ipxe.git ${project_root}/ipxe &&

# nano config/console.h # uncomment CONSOLE_SERIAL if you need it.

# See: https://ipxe.org/appnote/buildtargets

# curl https://letsencrypt.org/certs/lets-encrypt-r3.pem \
#  -o ${project_root}/le-r3.pem &&
openssl s_client -connect paul-grozav.github.io:443 2>/dev/null 0</dev/null |
  openssl x509 > ${project_root}/gh.pem &&

# Enable HTTPS support in header source file
sed -e $'s/^#undef\tDOWNLOAD_PROTO_HTTPS\t/#define\tDOWNLOAD_PROTO_HTTPS\t/g' \
  -i ${project_root}/ipxe/src/config/general.h &&
grep DOWNLOAD_PROTO_HTTPS ${project_root}/ipxe/src/config/general.h &&

# Make .iso
(
  DEBUG="dhcp" &&
  DEBUG="${DEBUG},tftp" &&
  DEBUG="${DEBUG},http" &&
  # DEBUG="${DEBUG},tls" &&
  # DEBUG="${DEBUG},x509:3" &&
  # DEBUG="${DEBUG},certstore" &&
  # DEBUG="${DEBUG},privkey" &&
  cd ${project_root}/ipxe/src &&
  make \
    -j$(nproc) \
    DEBUG=${DEBUG} \
    TRUST=${project_root}/gh.pem \
    EMBED=${project_root}/iso/embedded.ipxe \
    ` # This needs to be a relative path, as defined in Makefile ` \
    bin/ipxe.iso \
    &&
  # mkdir -p ./bin && touch ./bin/ipxe.iso &&
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

# cp ${project_root}/ipxe/src/bin/ipxe.lkrn ${project_root}/http/ &&
cp ${project_root}/ipxe/src/bin/ipxe.iso ${project_root}/http/ &&
exit 0
# ============================================================================ #
