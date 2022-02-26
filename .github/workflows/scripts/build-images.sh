#!/usr/bin/env bash
# Build images for all of the platforms we support
set -e

platforms=(raspberrypi3-64 raspberrypi4-64)

echo "::group::Configuration"
echo "  platforms='${platforms[*]}'"
echo "::endgroup::"

for platform in "${platforms[@]}"; do
  echo "::group:: Build image for $platform"
  ./balena-yocto-scripts/build/barys -m "$platform" --development-image -c
  echo "::endgroup::"
done

echo "Uploading image(s)"

build_urls=()
for image in ./build/tmp/deploy/images/raspberrypi*-64/balena-image-raspberrypi*-64-**.rootfs.balenaos-img.xz; do
  echo " -> $image"
  gsutil cp "$image" "gs://yoctobuild-artifacts/"

  build_urls+=("https://storage.cloud.google.com/yoctobuild-artifacts/$(basename "$image")")
done

echo "URLs: ${build_urls[*]}"
