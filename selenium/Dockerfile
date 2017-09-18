FROM ubuntu:16.04
LABEL authors="IgorV <gorvin@users.noreply.github.com>"

ARG APP_USER=app
EXPOSE 4444 4480

COPY bootstrap_selenium.sh /tmp/
RUN /tmp/bootstrap_selenium.sh \
    && rm -f /tmp/bootstrap_selenium.sh

COPY selenium_entry.sh selenium-bravo-servlet-1.0-SNAPSHOT.jar /opt/selenium/
RUN chmod a+x /opt/selenium/selenium_entry.sh \
    && ln -s selenium-bravo-servlet-1.0-SNAPSHOT.jar /opt/selenium/selenium-bravo-servlet.jar \
    && mkdir -p /tmp/.X11-unix /run/dbus /run/xpra /run/user/1000 \
    && chmod -R a+rwx /tmp/.X11-unix /run/dbus /run/xpra /run/user

RUN adduser --disabled-password --uid 1000 --home /home/${APP_USER} --gecos '' ${APP_USER} \
    && passwd -d ${APP_USER}\
    && echo "192.168.33.1 host" >> /etc/hosts \
    && usermod -a -G xpra,tty,video,dialout ${APP_USER}

ENV HEADLESS_XSERVER=true \
    DBUS_SESSION_BUS_ADDRESS=/dev/null
WORKDIR /home/${APP_USER}/
USER ${APP_USER}
ENTRYPOINT "/opt/selenium/selenium_entry.sh"
