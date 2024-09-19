#!/usr/bin/env bash
# Fastest way to get a basic debian qemu image up and running for native host.
# See
#  https://gist.github.com/richardweinberger/603154713fe4bb9aa986ad78be8055d4
#
# To install QEMU check out
#  https://wiki.debian.org/QEMU#Installation
#

SKIP="${1:-yes}"
DISTRO_URL=PREFIX="https://cloud.debian.org/images/cloud/bookworm/latest"
RAW_IMAGE="debian-12-nocloud-amd64.raw"
SHASUM_FILE="SHA512SUMS"
HASH="512"

if [ "$SKIP" != "yes" ]
    # Get image
    curl -O ${DISTRO_URL=PREFIX}/${RAW_IMAGE}

    # Check sha
    SUM="$(curl -s ${DISTRO_URL=PREFIX}/SHASUM_FILE | awk \
         -v image="${RAW_IMAGE}" '$2 == image {print $1}')"

    echo "$SUM *./${RAW_IMAGE}" | shasum -a "$HASH" --check

    if [ "$?" -eq "1" ]; then
        printf "ERROR: Not the same shasum. Fail.\n"
        exit 1
    fi
fi

# Start qemu
# Special settings:
# - Map port 22 to 5573
# Use -kernel and -append flags for custom kernel boot
qemu-system-x86_64 \
  -machine pc,accel=kvm \
  -m 1G \
  -drive file=./debian-12-nocloud-amd64.raw,if=virtio \
  -netdev type=user,hostfwd=tcp::5573-:22,id=net0 \
  -device virtio-net,netdev=net0 \
  -rtc base=localtime \
  -smp 4 \
  -nographic
