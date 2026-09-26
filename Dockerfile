# Ubuntu 26.04 with Python 3
# The image version is taken from config.sh and passed in by the Makefile
# as build argument VERSION (see "Image metadata" below).

# -------------------------------------------------------------------
# Base image
# Official Ubuntu base image from Docker Hub
# https://hub.docker.com/_/ubuntu
# -------------------------------------------------------------------
FROM ubuntu:26.04

##### Configure timezone #####################################################

ENV TZ=Europe/Berlin

# -------------------------------------------------------------------
# Install base utilities, Python runtime and PostgreSQL client
# Configure timezone and locale
#
# --no-install-recommends avoids installing optional packages
# which keeps the image smaller.
#
# Packages installed:
#   ca-certificates       trusted SSL certificates
#   curl                  HTTP client
#   dnsutils              DNS tools (dig, nslookup)
#   iproute2              networking tools (ip command)
#   iputils-ping          ping utility
#   locales               locale generation
#   net-tools             classic networking tools (netstat etc.)
#   postgresql-client-18  PostgreSQL command line client (psql)
#   python-is-python3     ensures "python" points to python3
#   python3               Python runtime
#   python3-venv          virtual environment support
#   redis-tools           redis-cli for debugging Redis
#   tzdata                timezone configuration
#   vim                   editor for interactive container use
# -------------------------------------------------------------------
RUN set -eux; \
    \
    # apt without interactive dialogs
    export DEBIAN_FRONTEND=noninteractive; \
    \
    # Update package lists
    apt-get update; \
    \
    # Install packages
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dnsutils \
        iproute2 \
        iputils-ping \
        locales \
        net-tools \
        postgresql-client-18 \
        python-is-python3 \
        python3 \
        python3-venv \
        redis-tools \
        tzdata \
        vim; \
    \
    # Configure timezone
    echo "$TZ" > /etc/timezone; \
    ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime; \
    \
    # Enable and generate German UTF-8 locale
    sed -i 's/^# *de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen; \
    locale-gen; \
    update-locale LANG=de_DE.UTF-8 LANGUAGE=de_DE:en; \
    \
    # Clean apt cache to keep image small
    rm -rf /var/lib/apt/lists/*


##### Configure locale #######################################################
# Set only after the locale has been generated above, otherwise apt and
# perl print "Setting locale failed" warnings during the build.

ENV LANG=de_DE.UTF-8
ENV LANGUAGE=de_DE:en
ENV LC_ALL=de_DE.UTF-8


##### Configure vim (optional) ###############################################
# Installs personal vim configuration inside the container

RUN mkdir -p /root/.vim/colors
COPY vim/.vimrc /root/.vimrc
COPY vim/badwolf.vim /root/.vim/colors/badwolf.vim


##### Set environment variables ##############################################
# Python container defaults:
#   PYTHONUNBUFFERED              logs appear immediately
#   PYTHONDONTWRITEBYTECODE       prevents .pyc files
#   PIP_DISABLE_PIP_VERSION_CHECK avoids pip update message
#   CONTAINER                     lets scripts detect that they run in a container

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV CONTAINER=true


##### Define useful aliases ##################################################
# Adds convenience aliases for interactive container sessions

RUN cat <<'EOF' >> /root/.bashrc
alias c="clear"
alias h="history"
alias act=". /opt/venv/bin/activate"
EOF


##### Create and activate a virtual environment ##############################
# Creates a Python virtual environment at /opt/venv
# Upgrades pip and installs wheel for faster package installs

ENV VIRTUAL_ENV=/opt/venv

RUN python3 -m venv "$VIRTUAL_ENV" \
 && "$VIRTUAL_ENV/bin/pip" install --no-cache-dir --upgrade pip wheel

ENV PATH="$VIRTUAL_ENV/bin:$PATH"


##### Image metadata #########################################################
# OCI labels. VERSION and CREATED are passed in by the Makefile.
# CREATED must be set here, otherwise the value of the base image is inherited.

ARG VERSION=dev
ARG CREATED=unknown

LABEL org.opencontainers.image.title="ubupy" \
      org.opencontainers.image.description="Ubuntu 26.04 with Python 3, a ready-to-use venv and common network/database CLI tools" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${CREATED}" \
      org.opencontainers.image.source="https://github.com/jennerwein/ubupy" \
      org.opencontainers.image.url="https://hub.docker.com/r/jennerwein/ubupy" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.base.name="docker.io/library/ubuntu:26.04"


##### Final setup ############################################################
# Working directory for subsequent operations

WORKDIR /app
