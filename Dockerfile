# Ubuntu with Python 3
# TAG: siehe File config.sh. Wird durch make-Befehle gesetzt.

# Base image
# https://hub.docker.com/_/ubuntu
FROM ubuntu:24.04

##### Configure timezone and locale ##########################################
# Sets timezone and locale to Europe/Berlin and German UTF-8
ENV TZ=Europe/Berlin
ENV LANG=de_DE.UTF-8
ENV LANGUAGE=de_DE:en

RUN set -eux; \
    DEBIAN_FRONTEND=noninteractive apt-get update; \
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
    echo "$TZ" > /etc/timezone; \
    ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime; \
    sed -i 's/^# *de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen; \
    locale-gen; \
    update-locale LANG=de_DE.UTF-8 LANGUAGE=de_DE:en; \
    install -m 0755 -d /etc/apt/keyrings; \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
      | gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg; \
    chmod 0644 /etc/apt/keyrings/postgresql.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] https://apt.postgresql.org/pub/repos/apt noble-pgdg main" \
      > /etc/apt/sources.list.d/pgdg.list; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        postgresql-client-18; \
    rm -rf /var/lib/apt/lists/*

##### Install utilities, Python, and PostgreSQL client #######################
# Basic tools, Python runtime, and PostgreSQL client for database access
# --no-install-recommends keeps the image smaller by avoiding optional packages

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
RUN python3 -m venv "$VIRTUAL_ENV" \
 && "$VIRTUAL_ENV/bin/pip" install --no-cache-dir --upgrade pip wheel

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

##### Final setup #############################################################
# Working directory for subsequent operations
WORKDIR /app