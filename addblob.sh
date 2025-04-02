#!/bin/bash
set -x
set -e # exit on non-zero status

# params
# $1: src
# $2: target
function addBlobOnChecksumChange() {
  src="$1"
  target="$2"
  blob_checksum=$(cat config/blobs.yml  | yq .'"'${target}'"'.sha)
  blob_object_id=$(cat config/blobs.yml  | yq .'"'${target}'"'.object_id) # With dev release, blobs are not publish yet, so we need to add it again
  src_checksum=$(cat "${src}"  | sha256sum |  cut -d " " -f1)
  if [ "${blob_checksum}" != "sha256:${src_checksum}" ] || [ "$blob_object_id" = "null" ]; then
    bosh add-blob ${src} ${target}
  else
    echo "skipping blob creation for ${target} with existing checksum: ${src_checksum}"
  fi
}

mkdir -p src/debs

pwd
addBlobOnChecksumChange src/debs/wireguard/wireguard_1.0.20210914-1ubuntu2_all.deb wireguard/wireguard.deb
addBlobOnChecksumChange src/debs/wireguard-tools/wireguard-tools_1.0.20210914-1ubuntu2_amd64.deb wireguard/wireguard-tools.deb

