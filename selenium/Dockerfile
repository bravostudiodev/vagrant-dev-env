FROM ubuntu:16.04
LABEL authors="IgorV <gorvin@users.noreply.github.com>"

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    TERM=linux

ARG APP_USER=app
EXPOSE 4444 4480

COPY bootstrap_00base.sh /tmp/
RUN chmod a+rwx /tmp/bootstrap_00base.sh \
    && sync \
    && /tmp/bootstrap_00base.sh

COPY bootstrap_01xpra.sh /tmp/
RUN chmod a+rwx /tmp/bootstrap_01xpra.sh \
    && sync \
    && /tmp/bootstrap_01xpra.sh

COPY bootstrap_02firefox.sh /tmp/
RUN chmod a+rwx /tmp/bootstrap_02firefox.sh \
    && sync \
    && /tmp/bootstrap_02firefox.sh

COPY bootstrap_03chrome.sh /tmp/
RUN chmod a+rwx /tmp/bootstrap_03chrome.sh \
    && sync \
    && /tmp/bootstrap_03chrome.sh

COPY bootstrap_04selenium.sh /tmp/
RUN chmod a+rwx /tmp/bootstrap_04selenium.sh \
    && sync \
    && /tmp/bootstrap_04selenium.sh

COPY selenium_entry.sh /opt/selenium/
RUN chmod a+x /opt/selenium/selenium_entry.sh \
    && sync \
    && mkdir -p /tmp/.X11-unix /run/dbus /run/xpra /run/user/1000 \
    && chmod -R a+rwx /tmp/.X11-unix /run/dbus /run/xpra /run/user

RUN adduser --disabled-password --uid 1000 --home /home/${APP_USER} --gecos '' ${APP_USER} \
    && passwd -d ${APP_USER}\
    && addgroup uinput \
    && usermod -a -G xpra,tty,video,dialout,uinput ${APP_USER}

ENV HEADLESS_XSERVER=true \
    DBUS_SESSION_BUS_ADDRESS=/dev/null
WORKDIR /home/${APP_USER}/
USER ${APP_USER}
ENTRYPOINT exec /opt/selenium/selenium_entry.sh

# docker rm -f selenium1; docker run -d -t --shm-size=2g --name selenium1 bravo-selenium:test
# xpra attach --no-opengl tcp:$(docker inspect -f '{{.NetworkSettings.IPAddress}}' selenium1):10000
