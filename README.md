*This project has been created as part of the 42 curriculum by mamorais.*

# Inception

## Description
**Inception** is a system administration project focused on building a small web infrastructure using Docker. The objective is to run multiple services inside isolated containers and make them work together as a complete system.

This project includes:
- **NGINX** (HTTPS server, single entry point)
- **WordPress** (PHP-FPM only, no web server inside)
- **MariaDB** (database)

Each service runs in its own container and communicates through a Docker network.
The goal is to understand:
- containerization
- service isolation
- secure configuration
- infrastructure orchestration

---

## Project Architecture

The infrastructure is built using:

- `docker-compose.yml` → defines services, volumes, networks, and secrets
- Dockerfiles → one for each service: mariadb, wordpress, nginx.
  - `srcs/requirements/nginx/Dockerfile`
  - `srcs/requirements/wordpress/Dockerfile`
  - `srcs/requirements/mariadb/Dockerfile`
- Initialization scripts:
  - `srcs/requirements/mariadb/tools/init_db.sh` for MariaDB
  - `srcs/requirements/wordpress/tools/init_wp.sh` for WordPress
  - `srcs/requirements/nginx/tools/entrypoint.sh` for NGINX

All services are connected through a private Docker network and only NGINX exposes port **443** to the outside.

---

## Project Structure
```
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets
│   ├── credentials.txt
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── wp_user_password.txt
└── srcs
    ├── docker-compose.yml
    └── requirements
        ├── mariadb
        │   ├── Dockerfile
        │   └── tools
        │       └── init_db.sh
        ├── nginx
        │   ├── conf
        │   │   └── default.conf
        │   ├── Dockerfile
        │   └── tools
        │       └── entrypoint.sh
        └── wordpress
            ├── Dockerfile
            └── tools
                └── init_wp.sh
```

---

## Instructions
### Requirements (VM)
- Run inside a **Virtual Machine**.
- Install:
  - Docker Engine
  - Docker Compose plugin

### Domain configuration
Add the project domain to `/etc/hosts` on the VM host system:

```bash
echo "127.0.0.1 mamorais.42.fr" | sudo tee -a /etc/hosts
```

### Secrets
Passwords are stored in `secrets/` and mounted into containers as Docker secrets under `/run/secrets/`:

- `db_root_password.txt` → MariaDB root password
- `db_password.txt` → WordPress database user password
- `credentials.txt` → WordPress admin password
- `wp_user_password.txt` → WordPress user password

> Passwords must not be hard-coded inside Dockerfiles or committed to the repository.

### Environment variables
Non-sensitive configuration lives in `srcs/.env`.

> The WordPress admin username must **not** contain `admin`, `administrator`, or similar names.

### Build & Run
From the repository root:
```bash
make
```

### Stop
```bash
make down
```

### Help
```bash
make help
```

## Technical Choices

### Virtual Machines vs Docker

- **Virtual Machines**
  - Run a full operating system
  - Higher resource usage
  - Slower startup

- **Docker**
  - Lightweight containers
  - Faster startup
  - Easier to reproduce environments

This project uses Docker to efficiently manage multiple services while running inside a Virtual Machine as required by the subject.

---

### Secrets vs Environment Variables

- **Environment Variables**
  - Easy to configure
  - Not secure for sensitive data

- **Docker Secrets**
  - Stored as files in `/run/secrets/`
  - More secure for passwords

This project uses environment variables for configuration and Docker secrets for sensitive data.

---

### Docker Network vs Host Network

- **Host Network**
  - No isolation
  - Less secure

- **Docker Network (bridge)**
  - Isolated communication
  - Containers communicate using service names

This project uses a bridge network for secure communication between services.

---

### Docker Volumes vs Bind Mounts

- **Bind Mounts**
  - Direct mapping to host filesystem
  - Requires manual management

- **Docker Volumes**
  - Managed by Docker
  - More portable and easier to handle

This project uses persistent storage located at:

- `/home/<your-user>/data/docker/`

---

## Resources
- Docker Documentation (containers, images, volumes, networks, Compose)
- Docker Compose Documentation
- NGINX Documentation (TLS/SSL, reverse proxy, FastCGI)
- WordPress Documentation + php-fpm
- WP-CLI Documentation
- MariaDB Documentation

### How AI was used
AI (ChatGPT) was used as a learning assistant to:
- Clarify the subject requirements.
- Review and improve documentation structure.
- Suggest validation ideas and sanity checks (connectivity checks, HTTPS-only verification).

All final implementation, configuration, and testing decisions were made and executed by the project author.

---

## Local Configuration

The repository intentionally does not include real environment variables or credentials.

Before running the project:

```bash
cp srcs/.env.example srcs/.env
```

Then configure the values for your local environment.

Create the required secret files inside `secrets/`:

```text
secrets/
├── credentials.txt
├── db_password.txt
├── db_root_password.txt
└── wp_user_password.txt
```

Real `.env` and secret files are excluded from Git.

---

## Public Project Showcase

A public technical showcase of this project is being prepared to demonstrate the architecture, infrastructure decisions and container topology without exposing credentials.

The original Inception implementation remains Docker-based and is designed to run inside a Linux virtual machine as required by the 42 project.
