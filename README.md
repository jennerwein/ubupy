# ubupy

Lightweight **Ubuntu 24.04** image with **Python 3** and **pip3**, including useful tools such as  
`postgresql-client`, `iproute2`, `curl`, and `redis-tools`.  
The image is localized for **German (de_DE)** environments.

📦 Available on Docker Hub:  
👉 [https://hub.docker.com/r/jennerwein/ubupy](https://hub.docker.com/r/jennerwein/ubupy)

## Makefile

The provided `Makefile` defines three commands:

| Command | Description |
|----------|--------------|
| `make build` | Removes the old test image (if it exists) and builds a new one. |
| `make run` | Starts the container interactively. |
| `make push` | Tags and pushes the image to Docker Hub (requires valid credentials and a `TAG` defined in `config.sh`). |

---

## Example usage

```bash
# Build the image
make build

# Run interactively
make run

# Push to Docker Hub (requires TAG)
make push
