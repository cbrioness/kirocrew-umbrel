# KiroCrew on Umbrel (ARM64 / aarch64)
#
# NOTE: This Dockerfile is a STARTING POINT and must be built and tested on the
# target Raspberry Pi (aarch64). The kiro-cli download URL and the kirocrew
# launch command may need adjustment once verified on real hardware.

FROM debian:bookworm-slim

# bookworm ships glibc >= 2.36, satisfying kiro-cli's glibc >= 2.34 requirement.

ENV DEBIAN_FRONTEND=noninteractive

# ---- System deps -----------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 \
      python3-pip \
      python3-venv \
      curl \
      ca-certificates \
      git \
      unzip \
    && rm -rf /var/lib/apt/lists/*

# ---- kiro-cli (ARM64 AppImage) ---------------------------------------------
# The Linux AppImage works across distros. If FUSE is unavailable in the
# container, extract it with --appimage-extract and symlink the AppRun binary.
RUN curl -fsSL -o /tmp/kiro-cli.appimage \
      https://desktop-release.q.us-east-1.amazonaws.com/latest/kiro-cli.appimage \
    && chmod +x /tmp/kiro-cli.appimage \
    && (cd /opt && /tmp/kiro-cli.appimage --appimage-extract || true) \
    && if [ -d /opt/squashfs-root ]; then \
         ln -s /opt/squashfs-root/AppRun /usr/local/bin/kiro-cli; \
       else \
         mv /tmp/kiro-cli.appimage /usr/local/bin/kiro-cli; \
       fi \
    && rm -f /tmp/kiro-cli.appimage

# ---- KiroCrew --------------------------------------------------------------
# Installed from the official release channel index (not on PyPI).
RUN python3 -m pip install --break-system-packages --pre kirocrew \
      --extra-index-url https://updates.crew.kiro.dev/feed/stable/simple/

# ---- Runtime ---------------------------------------------------------------
EXPOSE 8117

# Launch the gateway/dashboard. Verify the exact subcommand and host/port flags
# against the installed kirocrew version on first run.
CMD ["python3", "-m", "kiro_crew", "gateway", "--host", "0.0.0.0", "--port", "8117"]
