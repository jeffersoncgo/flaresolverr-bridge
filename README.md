<h1 align="left">
  <img src="https://raw.githubusercontent.com/FortAwesome/Font-Awesome/6.x/svgs/solid/network-wired.svg" width="42" style="vertical-align:middle; margin-right:10px;" />
  Flaresolverr Bridge
</h1>

<p align="left"><em>Manage and monitor your distributed targets</em></p>


---

This bridge provides a single, reliable endpoint for your applications (like Prowlarr, Sonarr, etc.) and intelligently distributes requests to your available FlareSolverr workers. It uses a "first-to-finish" strategy, returning a response from the fastest available FlareSolverr instance while canceling slower requests. It also includes a simple web UI to manage and monitor your FlareSolverr targets in real-time.

## ✨ Features

- **🚀 High-Performance Proxy**: Forwards requests to multiple FlareSolverr instances.
- **⚡ Smart Load Balancing**: Uses `Promise.any` to return a response from the *fastest* available FlareSolverr instance, immediately aborting slower ones.
- **🔄 Automatic Failover**: If a primary instance is slow or fails, the bridge automatically uses the next fastest one.
- **🖥️ Web UI**: A clean user interface to add, remove, and monitor the status (online/offline) and latency of your FlareSolverr targets.
- **💾 Persistent Configuration**: Target instances are saved in a `targets.json` file, so your configuration persists across restarts. This is optional.
- **⚙️ Configurable Port**: Set a custom port for the bridge using a command-line argument or an environment variable.
- **🧩 Simple API**: Easy-to-use API endpoints for programmatic management of targets.
- **🐳 Dockerized**: Ready for deployment with a pre-built image on Docker Hub or by building from source.

---

## 🚀 Getting Started

You can run FlareSolverr-Bridge using Docker (recommended) or directly with Node.js.

### Prerequisites

- [Docker](https://www.docker.com/get-started/) & [Docker Compose](https://docs.docker.com/compose/install/) (for containerized deployment)
- [Node.js](https://nodejs.org/) (if running locally without Docker)

---

## 🛠️ Installation & Usage

### Option 1: Docker Compose (Recommended)

This is the easiest and most reliable way to run the bridge.

#### A) Production with Pre-Built Image

This method uses the official, pre-built image from Docker Hub, ensuring you have a stable version.

1.  Download the `compose.prod.yml` file or copy the content below.
2.  (Optional) Create a directory on your host machine to store the configuration (e.g., `/my/appdata/flaresolverr-bridge`).
3.  (Optional) Edit the `volumes` section in the file to point to the directory you just created.

**`compose.prod.yml`:**
```yaml
services:
  flaresolverr-bridge:
    container_name: flaresolverr-bridge
    # Uses the official pre-built image from Docker Hub
    image: jeffersoncgo/flaresolverr-bridge
    ports:
      - "8195:3000" # Exposes container port 3000 on host port 8195
    environment:
      # You can set the internal port via an environment variable
      - port=3000
    volumes:
      # The 'volumes' section is optional.
      # Use it only if you want to persist the `targets.json` file across container restarts
      # or if you plan to modify the application's scripts.
      # If you omit this, the bridge will run statelessly.
      # 👇 CHANGE THIS to your actual host path if you use it.
      - /path/to/your/appdata/flaresolverr-bridge:/app
    restart: unless-stopped
```

4.  Start the container from the same directory as your `compose.prod.yml` file:
    ```bash
    docker-compose -f compose.prod.yml up -d
    ```

#### B) Development with Local Build

This method builds the Docker image from the source code in the current directory. Use this if you have made local modifications.

1.  Clone the repository.
2.  Create a `compose.build.yml` file with the content below.

**`compose.build.yml`:**
```yaml
services:
  flaresolverr-bridge:
    container_name: flaresolverr-bridge
    # Builds the image from the Dockerfile in the current directory
    build: .
    image: flaresolverr-bridge-local # Optional name for the built image
    ports:
      - "8195:3000"
    environment:
      - port=3000
    volumes:
      # This is optional and mainly for development to see live code changes.
      - ./ :/app
    restart: unless-stopped
```
4.  Start the container:
    ```bash
    docker-compose -f compose.build.yml up -d
    ```

---

### Option 2: Docker CLI (without Compose)

If you prefer not to use Docker Compose, you can run the pre-built container directly from the command line.

1.  **Run the container:**
    This command pulls the pre-built image and runs it.

    ```bash
    docker run -d \
      --name flaresolverr-bridge \
      -p 8195:3000 \
      -e port=3000 \
      --restart unless-stopped \
      jeffersoncgo/flaresolverr-bridge
    ```
    - `-p 8195:3000`: Maps port `8195` on your host to the container's internal port.
    - `-e port=3000`: Sets the application's internal port. This must match the second part of the `-p` mapping.
    
    **To persist your targets:** If you want to keep your `targets.json` configuration after updating the container, you must add a volume mount.
     1. Create a directory on your host: `mkdir -p /path/to/your/appdata/flaresolverr-bridge`
     2. Add the `-v` flag to your run command:
    ```bash
      -v /path/to/your/appdata/flaresolverr-bridge:/app \
    ```
    The `-v` flag is optional. Without it, the bridge is stateless, and you will need to re-add your targets if the container is recreated.

---

### Option 3: Node.js (without Docker)

Use this method for local development or if you don't want to use Docker.

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/flaresolverr-bridge.git](https://github.com/your-username/flaresolverr-bridge.git)
    cd flaresolverr-bridge
    ```
2.  **Install dependencies:**
    ```bash
    npm install
    ```
3.  **Start the application:**
    ```bash
    # Start on the default port (3000)
    npm start

    # Or start on a custom port (e.g., 8080)
    # The '--' is important to pass the argument to the script
    npm start -- --port 8080
    ```
    The bridge will be running at `http://localhost:<port>`.

---

## ⚙️ How to Use

### Web Interface

Once the application is running, open your web browser and navigate to the bridge's URL (e.g., `http://<your-server-ip>:8195`).

From the UI, you can:
- **Add new FlareSolverr instances** by entering their full URL (e.g., `http://192.168.1.100:8191`).
- **See the real-time status** (online/offline) and latency of each instance.
- **Delete** existing instances with a single click.

The status list auto-refreshes every 5 seconds.

### Proxy Usage

To use the bridge in your applications (e.g., Prowlarr, Jackett), simply point them to the bridge's URL instead of a single FlareSolverr instance. The bridge exposes the standard FlareSolverr `/v1` endpoint.

**Proxy URL:** `http://<bridge-ip>:<port>`

For example, in Prowlarr, you would set the FlareSolverr address to `http://localhost:8195` (if running on the same machine). The bridge handles the rest.

### API Endpoints

You can also manage targets programmatically via the API.

- `GET /api/targets`: Returns a JSON array of all configured target URLs.
- `POST /api/targets`: Adds a new target. The body must be a JSON object: `{ "url": "http://..." }`.
- `DELETE /api/targets`: Removes a target. The body must be a JSON object: `{ "url": "http://..." }`.
- `GET /api/ping`: Pings all targets and returns a JSON array with their status and latency.
