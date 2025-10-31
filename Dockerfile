# Ubuntu with Python 3
# TAG=2.0.1      # with Wheel

# Base image
# https://hub.docker.com/_/ubuntu
FROM ubuntu:24.04

##### Configure timezone and locale ##########################################
# Sets timezone and locale to Europe/Berlin and German UTF-8
ENV DEBIAN_FRONTEND=noninteractive TZ=Europe/Berlin
ENV LANG=de_DE.UTF-8 LANGUAGE=de_DE:en

RUN apt-get update \
 && apt-get install -y --no-install-recommends tzdata locales \
 && echo "$TZ" > /etc/timezone \
 && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
 && sed -i 's/^# *de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
 && locale-gen \
 && update-locale LANG=de_DE.UTF-8 LANGUAGE=de_DE:en \
 && rm -rf /var/lib/apt/lists/*

##### Install utilities, Python, and PostgreSQL client #######################
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    vim \
    iproute2 \
    iputils-ping \
    curl \
    dnsutils \
    net-tools \
    redis-tools \
    python3-pip \
    python-is-python3 \
    python3-venv \
    gnupg \
    ca-certificates \
    lsb-release; \
  install -m 0755 -d /etc/apt/keyrings && \
  curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    | gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg && \
  chmod 0644 /etc/apt/keyrings/postgresql.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt noble-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends postgresql-client-18 && \
  rm -rf /var/lib/apt/lists/*

##### Configure vim (optional) ###############################################
RUN mkdir -p /root/.vim/colors
COPY vim/.vimrc /root/.vimrc
COPY vim/badwolf.vim /root/.vim/colors/badwolf.vim

##### Set environment variables ##############################################
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV CONTAINER=true

##### Define useful aliases ###################################################
RUN cat <<'EOF' >> /root/.bashrc
alias c="clear"
alias h="history"
alias act=". /opt/venv/bin/activate"
EOF

##### Create and activate a virtual environment ##############################
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv "$VIRTUAL_ENV" && \
    "$VIRTUAL_ENV/bin/python" -m ensurepip && \
    "$VIRTUAL_ENV/bin/pip" install --upgrade pip setuptools wheel
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
##### Final setup #############################################################
# Working directory for subsequent operations
WORKDIR /app
