# KiroCrew — Umbrel Community App Store

A [Community App Store](https://github.com/getumbrel/umbrel-community-app-store)
for umbrelOS that packages **KiroCrew**, the autonomous AI agent layer that runs
on top of `kiro-cli`.

> **Status: work in progress.** The Docker image builds are not yet verified on
> real Raspberry Pi (aarch64) hardware. See [Known caveats](#known-caveats).

## Add this store to your Umbrel

1. Open your umbrelOS dashboard.
2. Go to **App Store → ⋯ (top right) → Community App Stores**.
3. Paste this repository URL:
   `https://github.com/cbrioness/kirocrew-umbrel`
4. **KiroCrew** now appears in your app list — click **Install**.

## Requirements

| Requirement | Value |
|-------------|-------|
| Architecture | ARM64 / aarch64 (Raspberry Pi 4/5) |
| RAM | 8 GB recommended (4 GB is tight alongside umbrelOS) |
| Storage | SSD over USB recommended (not microSD alone) |
| glibc | ≥ 2.34 (provided by the Debian base image) |
| Python | ≥ 3.10 (installed inside the container) |

## Post-install: authenticate kiro-cli (required)

KiroCrew cannot talk to the LLM until `kiro-cli` is logged in. This is a
**one-time interactive step**:

1. Open a shell into the running container (via Umbrel's terminal, or SSH to the
   Pi and `docker exec -it cbrioness-kirocrew_web_1 bash`).
2. Run:
   ```bash
   kiro-cli login
   ```
3. It prints a URL + device code. Open the URL on any device with a browser,
   enter the code, and authorize.
4. The credential is persisted to the mounted volume, so it survives restarts.

## Files in this store

```
umbrel-app-store.yml          # store id + name
cbrioness-kirocrew/
  umbrel-app.yml              # app listing shown in the umbrelOS UI
  docker-compose.yml          # how the container is launched
  Dockerfile                  # builds KiroCrew + kiro-cli for ARM64
```

## Known caveats

These are the items that still need verification on a real Pi before this is
production-ready:

1. **kiro-cli download URL / format** — the ARM64 AppImage URL and its
   extraction path inside the container must be confirmed on aarch64.
2. **kirocrew launch command & flags** — the exact `gateway` subcommand and the
   `--host` / `--port` flag names must be validated against the installed
   kirocrew version.
3. **Interactive login inside a container** — the device-login flow needs to be
   confirmed to work from a container shell on a headless Pi.
4. **Embedding model download** (~610 MB) happens on first start and needs disk
   headroom and time.

Contributions and fixes welcome via issues/PRs.
