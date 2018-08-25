FROM registry.gitlab.com

ENV REFRESHED_AT 2016-06-01
ENV DISPLAY :1
ENV NO_VNC_HOME /root/noVNC
ENV VNC_COL_DEPTH 24
ENV VNC_RESOLUTION 800x600
ENV VNC_PW vncpassword

RUN yum install firefox -y


# xvnc installation
RUN yum install -y epel-release && \
    yum update -y && \
    yum install -y sudo && \
    yum clean all && \
    yum groups install -y "Fonts" && \
    yum install -y \
        tigervnc-server \
        net-tools

# Install needed libraries for running GUI apps like nuke
RUN yum install -y \
        libxinerama-dev \
        libXft \
        libXi \
        libGLU \
        libXv \
        SDL-1.2.15-14* \
        alsa-lib-1.0.28-2* \
        mesa-libGLU-9.0.0-4*

# Install some libraries required to run apps like Maya
RUN yum install -y libXrandr mesa-libGLw csh libXp libXp-devel gamin audiofile audiofile-devel e2fsprogs-libs tcsh libpng12 libXpm.so.4 libXpm libtiff libtiff.so.3 compat-libtiff3 gstreamer-plugins-base-0.10.36-10.el7.i686 gstreamer-plugins-base tbb-4.1-9.20130314.el7.i686 tbb lbX11 ibXrandr libXinerama xorg-x11-fonts-100dpi.noarch xorg-x11-fonts-75dpi.noarch xorg-x11-fonts-ISO8859-1-100dpi.noarch xorg-x11-fonts-ISO8859-1-75dpi.noarch xorg-x11-fonts-ISO8859-14-100dpi.noarch xorg-x11-fonts-ISO8859-14-75dpi.noarch xorg-x11-fonts-ISO8859-15-100dpi.noarch xorg-x11-fonts-ISO8859-15-75dpi.noarch xorg-x11-fonts-ISO8859-2-100dpi.noarch xorg-x11-fonts-ISO8859-2-75dpi.noarch xorg-x11-fonts-ISO8859-9-100dpi.noarch xorg-x11-fonts-ISO8859-9-75dpi.noarch xorg-x11-fonts-Type1.noarch xorg-x11-fonts-cyrillic.noarch xorg-x11-fonts-ethiopic.noarch xorg-x11-fonts-misc.noarch


# Install noVNC - HTML5 based VNC viewer
RUN mkdir -p $NO_VNC_HOME/utils/websockify && \
    wget -qO- https://github.com/ConSol/noVNC/archive/consol_1.0.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME && \
    wget -qO- https://github.com/kanaka/websockify/archive/v0.7.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify && \
    chmod +x -v /root/noVNC/utils/*.sh

RUN /bin/dbus-uuidgen > /etc/machine-id

RUN rm  /root/noVNC/images/favicon.ico
# xvnc server porst, if $DISPLAY=:1 port will be 5901
EXPOSE 5901
# novnc web port
EXPOSE 6901
WORKDIR /tmp
ADD .vnc /root/.vnc
ADD .config /root/.config
ADD scripts /root/scripts
ADD vnc_auto.html /root/noVNC
ADD rfb.js /root/noVNC/include
RUN chmod +x  /root/scripts/*.sh /root/.vnc/xstartup

ENTRYPOINT ["/root/scripts/vnc_startup.sh"]
CMD ["--tail-log"]
