#!/usr/bin/env bash

: ${SELENIUM_PORT:=4444} # As integer, maps to "port"
: ${BRAVOEXT_PORT:=4480}
: ${HEADLESS_XSERVER:=false}
: ${DISPLAY=":100.0"}

echo "starting node with configuration:"
cat <<EOF
SELENIUM_PORT=${SELENIUM_PORT}
BRAVOEXT_PORT=${BRAVOEXT_PORT}
HEADLESS_XSERVER=${HEADLESS_XSERVER}
JAVA_OPTS=${JAVA_OPTS}
EOF

function shutdownhandler {
  echo "shutting down node.."
  # trap - SIGTERM && kill -- -$$
  # pkill -P $$
  killall java
  killall xpra
  wait ${XSRV_PID}
  killall dbus-daemon
  echo "shutdown complete"
}

function wait_xserver {
  while ! xset q >/dev/null 2>&1; do
    sleep 0.50s
  done
}

touch ~/.Xmodmap ~/.Xauthority
mkdir -p ~/.fluxbox
grep -q -F 'background: unset' ~/.fluxbox/overlay || echo 'background: unset' >> ~/.fluxbox/overlay

#xinit /usr/bin/java -jar /opt/selenium/selenium-server-standalone.jar -- :100 -dpi 96 -noreset -nolisten tcp +extension GLX +extension RANDR +extension RENDER -logfile ${HOME}/XpraXorg-10.log -config /etc/xpra/xorg.conf

rm -f /tmp/.X*lock

if ${HEADLESS_XSERVER}; then
  XORG_CONF="-config /etc/xpra/xorg.conf" # Dummy video driver
  XORG_LOG="-logfile ${HOME}/XpraXorg${DISPLAY}.log"
else
  XORG_CONF=""
  XORG_LOG=""
fi
XORG_EXTENSIONS="+extension GLX +extension RANDR +extension RENDER"
XORG_ARGS="-dpi 96 -noreset -nolisten tcp ${XORG_EXTENSIONS} ${XORG_LOG} ${XORG_CONF}"

set -x

export DISPLAY=${DISPLAY}

XPRA_INITENV_COMMAND="xpra initenv" xpra --no-daemon --no-mdns --no-pulseaudio \
  --xvfb="/usr/bin/Xorg ${XORG_ARGS}" \
  start-desktop ${DISPLAY} --start="xrandr --output VGA-1 --mode 1440x900" --exit-with-children --start-child="exec fluxbox" \
  --bind-tcp=0.0.0.0:10000 &
XSRV_PID=$!

wait_xserver
/usr/bin/java ${JAVA_OPTS} -jar /opt/selenium/selenium-server-standalone.jar -port ${SELENIUM_PORT} &
#JAVA_PID=$!
/usr/bin/java ${JAVA_OPTS} -jar /opt/selenium/selenium-bravo-servlet.jar server ${BRAVOEXT_PORT} &

# Specifying signal EXIT is useful when using set -e
trap shutdownhandler SIGTERM SIGINT EXIT
wait ${XSRV_PID}
