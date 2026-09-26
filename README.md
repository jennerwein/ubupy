# ubupy

Lightweight **Ubuntu 26.04** image with **Python 3**, a ready-to-use virtual
environment and a set of command line tools for debugging networks, Redis and
PostgreSQL inside container environments.
The image is localized for **German (de_DE)** environments.

📦 Docker Hub: [jennerwein/ubupy](https://hub.docker.com/r/jennerwein/ubupy)

## Quick start

```bash
docker pull jennerwein/ubupy:latest
docker run --rm -it jennerwein/ubupy:latest
```

Mount your current directory into the container's working directory `/app`:

```bash
docker run --rm -it -v "$PWD":/app jennerwein/ubupy:latest
```

## What's inside

| Category | Contents |
|----------|----------|
| Base image | `ubuntu:26.04` |
| Python | `python3` (also available as `python`), `python3-venv` |
| Virtual environment | `/opt/venv` with upgraded `pip` and `wheel`, already on `PATH` |
| Network tools | `curl`, `dig`/`nslookup`, `ip`, `ping`, `netstat` |
| Database clients | `psql` (PostgreSQL 18), `redis-cli` |
| Editor | `vim` with the [Badwolf](https://github.com/sjl/badwolf) color scheme |

### Python and pip

There is no system-wide `pip`. Instead, the virtual environment `/opt/venv` is
active by default (its `bin` directory is first on `PATH`), so `python` and
`pip` refer to the venv:

```bash
pip install requests
python -c "import requests; print(requests.__version__)"
```

### Environment

| Variable | Value | Purpose |
|----------|-------|---------|
| `TZ` | `Europe/Berlin` | Timezone |
| `LANG`, `LC_ALL` | `de_DE.UTF-8` | German UTF-8 locale |
| `LANGUAGE` | `de_DE:en` | German messages, English fallback |
| `VIRTUAL_ENV` | `/opt/venv` | Python virtual environment |
| `PYTHONUNBUFFERED` | `1` | Unbuffered Python output (logs appear immediately) |
| `PYTHONDONTWRITEBYTECODE` | `1` | No `.pyc` files |
| `PIP_DISABLE_PIP_VERSION_CHECK` | `1` | No pip update notice |
| `CONTAINER` | `true` | Lets scripts detect that they run in a container |

The working directory is `/app`.

### Shell aliases

| Alias | Command |
|-------|---------|
| `c` | `clear` |
| `h` | `history` |
| `act` | `. /opt/venv/bin/activate` (adds the venv name to the prompt) |

> **Note:** The container runs as `root`. It is intended as an interactive
> tool and debugging image, not as a hardened runtime for production services.

## Tags

| Tag | Description |
|-----|-------------|
| `latest` | Most recent stable release |
| `3.x.y` | Specific release, see [CHANGELOG.md](CHANGELOG.md) |
| `*-dev` | Development builds |

## Building the image yourself

The `Makefile` wraps the Docker commands. The version tag and whether `latest`
is updated are configured in [`config.sh`](config.sh).

| Command | Description |
|---------|-------------|
| `make build` | Removes the old test image (if it exists) and builds a fresh one (`jennerwein/ubupy:test`) from the latest base image. |
| `make run` | Starts the test image interactively. |
| `make push` | Tags the test image with `TAG` from `config.sh` and pushes it to Docker Hub. Also pushes `latest` if `latest=true`. Requires `docker login`. |
| `make update` | Runs `build` and `push`, e.g. to pick up security updates of the base image. |
| `make help` | Shows the available targets. |

```bash
make build   # build jennerwein/ubupy:test
make run     # try it out
make push    # publish (requires Docker Hub credentials)
```

To publish under your own Docker Hub account, change `IMAGE` in the `Makefile`.

## License

This project is licensed under the [MIT License](LICENSE).

The Vim color scheme [`vim/badwolf.vim`](vim/badwolf.vim) is © Steve Losh and
contributors and is distributed under the MIT/X11 License, see
[`vim/LICENSE-badwolf`](vim/LICENSE-badwolf).
