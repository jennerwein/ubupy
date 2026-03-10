# Ubuntu with Python 3
# TAG: siehe File config.sh. Wird durch make-Befehle gesetzt.

# -------------------------------------------------------------------
# Base image
# Official Ubuntu base image from Docker Hub
# https://hub.docker.com/_/ubuntu
# -------------------------------------------------------------------
FROM ubuntu:26.04


##### Configure timezone and locale ##########################################
# Sets timezone and locale to Europe/Berlin and German UTF-8

ENV TZ=Europe/Berlin
ENV LANG=de_DE.UTF-8
ENV LANGUAGE=de_DE:en


# -------------------------------------------------------------------
# Install base utilities and Python runtime
# Configure timezone and locale
#
# --no-install-recommends avoids installing optional packages
# which keeps the image smaller.
#
# Packages installed:
#   tzdata            timezone configuration
#   locales           locale generation
#   vim               editor for interactive container use
#   iproute2          networking tools (ip command)
#   iputils-ping      ping utility
#   curl              HTTP client
#   dnsutils          DNS tools (dig, nslookup)
#   net-tools         classic networking tools (netstat etc.)
#   redis-tools       redis-cli for debugging Redis
#   python3           Python runtime
#   python3-venv      virtual environment support
#   python-is-python3 ensures "python" points to python3
#   gnupg             cryptographic utilities
#   ca-certificates   trusted SSL certificates
# -------------------------------------------------------------------
RUN set -eux; \
    \
    # Update package lists
    DEBIAN_FRONTEND=noninteractive apt-get update; \
    \
    # Install base packages and Python runtime
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        tzdata \
        locales \
        vim \
        iproute2 \
        iputils-ping \
        curl \
        dnsutils \
        net-tools \
        redis-tools \
        python3 \
        python3-venv \
        python-is-python3 \
        gnupg \
        ca-certificates; \
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


##### Configure vim (optional) ###############################################
# Installs personal vim configuration inside the container

RUN mkdir -p /root/.vim/colors
COPY vim/.vimrc /root/.vimrc
COPY vim/badwolf.vim /root/.vim/colors/badwolf.vim


##### Set environment variables ##############################################
# Python container defaults:
#   PYTHONUNBUFFERED            logs appear immediately
#   PYTHONDONTWRITEBYTECODE     prevents .pyc files
#   PIP_DISABLE_PIP_VERSION_CHECK avoids pip update message

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


##### Final setup ############################################################
# Working directory for subsequent operations

WORKDIR /app