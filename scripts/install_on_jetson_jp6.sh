#!/bin/bash -e

# JetPack 6 (L4T r36.x, Ubuntu 22.04, Python 3.10). For JetPack 5 use
# install_on_jetson_jp5.sh. The two are separate scripts rather than one with a
# release check because they disagree on two things that cannot be detected
# reliably from inside a container build: how Compose is installed, and which
# ml_api base image the board can run.

sudo apt update && sudo apt install -y libhdf5-dev libssl-dev python3-pip
sudo systemctl restart docker

# Compose v2 is a docker CLI plugin, not a pip package. The JetPack 5 script
# installs docker-compose 1.29 from pip, which does not build on the Python
# 3.10 that JetPack 6 ships. JetPack 6 images already carry the plugin; the
# apt package covers a board where it was removed or never installed.
if ! sudo docker compose version > /dev/null 2>&1; then
  sudo apt install -y docker-compose-plugin
fi

# No `version:` key: Compose v2 ignores it and warns that it is obsolete.
#
# The build arg is what selects the JetPack 6 base. Without it ml_api is built
# on the default base tag, which is a JetPack 4.6 rootfs, and an L4T container
# only runs on the BSP it was built for — the build would succeed and the
# container would fail on the board.
cat <<EOT >docker-compose.override.yml
services:
  ml_api:
    build:
      context: ml_api
      args:
        IMAGE_TAG_SUFFIX: -jp6
    runtime: nvidia
EOT

# The JetPack 6 base is not published on Docker Hub, so try to pull it and
# build it if that fails. Building it is the slow part of this script — it pulls
# the full JetPack SDK container to compile darknet against CUDA 12 — which is
# why it is skipped whenever the image is already present under the exact name
# ml_api/Dockerfile resolves its FROM to.
BASE_IMAGE=thespaghettidetective/ml_api_base:1.4-jp6
if ! sudo docker image inspect "${BASE_IMAGE}" > /dev/null 2>&1; then
  if ! sudo docker pull "${BASE_IMAGE}" > /dev/null 2>&1; then
    echo "Building ${BASE_IMAGE}. This takes a while."
    sudo docker build --platform linux/arm64 -f ml_api/Dockerfile.base_arm64_jp6 \
      -t "${BASE_IMAGE}" ml_api
  fi
fi

# --build because the base tag differs from the default one: an ml_api image
# left behind by an earlier attempt would otherwise be reused as-is, and it
# would be the wrong one.
sudo docker compose up -d --build

sudo systemctl enable docker

while true; do
  read -p "Would you like to configure this Jetson device so it can be addressed by 'obico.local' on your local network? [N/y/d]: " -e -i "N" ynd
  case $ynd in
    [Yy]* ) sudo $(dirname "$0")/avahi_setup_jetson.sh; break;;
    [Nn]* ) break;;
    [Dd]* ) echo "Read More Here: https://www.obico.io/docs/server-guides/configure/";;
  esac
done
