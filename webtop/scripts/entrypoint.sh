#!/bin/bash
# set -e: exit asap if a command exits with a non-zero status
set -e

#
# --- Set Custom DNS at Startup ---
# This section overwrites the container's default /etc/resolv.conf.
# We use 'sudo tee' because this script may be run by a non-root user,
# but root privileges are required to modify /etc/resolv.conf.
#
# NOTE: The 'sudo' package must be installed in the Docker image for this to work.
# (e.g., RUN apt-get update && apt-get install -y sudo)
#
echo "Configuring DNS to use Cloudflare Family (1.1.1.3, 1.0.0.3)..."
echo "nameserver 1.1.1.3" | sudo tee /etc/resolv.conf > /dev/null
echo "nameserver 1.0.0.3" | sudo tee -a /etc/resolv.conf > /dev/null
echo "DNS configuration complete."
# --- End Custom DNS Section ---


# Trap for graceful shutdown
trap ctrl_c INT
function ctrl_c() {
  echo "Ctrl-C received, shutting down..."
  exit 0
}


# --- Original Script Logic ---
# Entrypoint for starting xvfb and VNC server.
echo "Cleaning up old X11 lock file..."
rm -f /tmp/.X1-lock 2> /dev/null || true

echo "Starting noVNC proxy..."
/opt/noVNC/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT &

echo "Starting VNC server on display $DISPLAY..."
# Insecure option is needed to accept connections from outside the container's localhost.
vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION -SecurityTypes None -localhost no --I-KNOW-THIS-IS-INSECURE &

echo "Entrypoint setup is complete. Processes are running in the background."
# Use wait to keep the script (and thus the container) running
wait
