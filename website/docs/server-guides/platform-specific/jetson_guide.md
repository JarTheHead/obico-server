---
title: Run Obico Server on an NVIDIA Jetson device
---

*If you follow this guide and run into problems, please seek help at: https://obico.io/discord*

## Prerequisites {#prerequisites}

### Hardware requirements {#hardware-requirements}

The Obico Server needs enough memory to run the program and the AI model at the same time. On a Jetson that means at least 4GB of RAM — the 2GB Jetson Nano does not have enough.

Which JetPack release your board runs is decided by the board, not by you, and the installer has to match it:

Board | JetPack release | Installer
:---|:---|:---
Jetson Orin Nano, Orin NX, AGX Orin | JetPack 6 | `install_on_jetson_jp6.sh`
Jetson AGX Xavier, Xavier NX, Orin | JetPack 5 | `install_on_jetson_jp5.sh`
Jetson Nano (original) | JetPack 4.6 | `install_on_jetson_jp5.sh`

If you are not sure which one you have, ask the board:

```bash
cat /etc/nv_tegra_release
```

`R36` is JetPack 6, `R35` is JetPack 5, `R32` is JetPack 4.6.

### Software requirements {#software-requirements}

**Important:** Before you flash new software on your sd card, you will have to fully format it first, so make sure you have backed up anything important on an external device.

The following software is required before you start installing the server:

- [JetPack SDK](https://developer.nvidia.com/embedded/jetpack), flashed onto the board. If you already flashed a different OS on your sd card, you will have to replace it with this one. Slow download of the software from NVIDIA is normal.
- [Flashing Software](https://www.balena.io/etcher/)
- [SD Card Formatter](https://www.sdcard.org/downloads/formatter/)

### Email delivery {#email-delivery}

You will also need an email account that has SMTP access enabled. For a gmail account, this is [how you enable SMTP access](https://support.google.com/accounts/answer/6010255?hl=en). Other web mail such as Yahoo
should also work but we haven't tried them.

## Get the code and start the server. {#get-the-code-and-start-the-server}

1. Get the code:

```bash
git clone -b release https://github.com/TheSpaghettiDetective/obico-server.git
```

2. Run the installer for your JetPack release:

```bash
cd obico-server
./scripts/install_on_jetson_jp6.sh    # JetPack 6
# or
./scripts/install_on_jetson_jp5.sh    # JetPack 5
```

3. Go grab a coffee. Step 2 will take 15-30 minutes, and longer on JetPack 6 the first time, when the base image has to be built.

4. There is no step 4. This is how easy it is to get the Obico Server up and running (thanks to Docker and Docker-compose).

## Why there are two installers {#why-there-are-two-installers}

The two scripts are not interchangeable, and running the wrong one produces a container that builds fine and then fails on the board.

- **The `ml_api` image is built on an L4T base, and an L4T container only runs on the BSP it was built for.** The JetPack 6 script passes `IMAGE_TAG_SUFFIX=-jp6` so `ml_api` is built on the JetPack 6 base. The JetPack 5 script is the original installer, unchanged apart from its name: it uses the default base, which is an L4T r32 (JetPack 4.6) rootfs — the base the original Jetson Nano runs, and the one every Jetson install has used so far. The CUDA and Tegra user space inside the image has to match the driver the board mounts in.
- **Compose is installed differently.** JetPack 5 ships Python 3.8, where `docker-compose` 1.x still installs from pip. JetPack 6 ships Python 3.10, where it does not build, so the JetPack 6 script uses the Compose v2 plugin (`docker compose`) that JetPack 6 already carries.

Both scripts write `docker-compose.override.yml` to give the `ml_api` container access to the GPU, and both offer to set up Avahi so the server answers to `obico.local` on your local network.

## Continue to [server configuration the main documentation](../../configure) {#continue-to-server-configuration-the-main-documentation}

*Thanks to the work of Raymond, LyricPants, and others for their contribution!*
