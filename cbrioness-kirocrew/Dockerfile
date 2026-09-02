# KiroCrew on Umbrel (ARM64 / aarch64)
#
# KiroCrew's dashboard binds LOOPBACK ONLY (127.0.0.1) by design and offers no
# --host flag. Umbrel's app_proxy reaches the app container over the Docker
# network (by container name), not over loopback, so a loopback-only listener
# is unreachable and the browser gets ERR_EMPTY_RESPONSE.
#
# Fix: run kirocrew on its internal loopback port (5476) and put a tiny socat
# bridge in front that listens on 0.0.0.0:8117 and forwards to 127.0.0.1:5476.

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
      socat \
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

# ---- Entrypoint: start kirocrew on 5476 + socat bridge on 8117 -------------
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8117
CMD ["/usr/local/bin/start.sh"]
