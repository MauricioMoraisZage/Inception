# Developer documentation

This document explains how a developer can prepare, run, manage, and maintain the project.

## Set up the environment from scratch

Before running the project, make sure the following tools are installed on the system:

- Docker
- Docker Compose
- make

You can verify them with:

```bash
docker --version
docker compose version
make --version
```

This project also requires local configuration files that should not be committed to the repository.

The main environment variables are stored in:

srcs/.env

Sensitive credentials are stored in secret files inside:

secrets/

Example files:
```
secrets/db_root_password.txt
secrets/db_password.txt
secrets/credentials.txt
secrets/wp_user_password.txt
```

These files contain the passwords required by MariaDB and WordPress. They are mounted inside containers as Docker secrets during runtime.

Before starting the project, verify that all secret files exist and contain valid values.

It is also necessary to configure the local domain in /etc/hosts:

echo "127.0.0.1 mamorais.42.fr" | sudo tee -a /etc/hosts

---

Build and launch the project

From the root of the repository, run:

make

This command prepares the required directories, builds the images, and starts the containers.

The infrastructure can also be started manually with Docker Compose:

```
cd srcs
docker compose build
docker compose up -d
```

This builds the images and launches the services in detached mode.

---

## Manage containers and volumes

To see the running containers:

```
docker ps
```

To view logs from all services:

```
docker compose -f srcs/docker-compose.yml logs
```

To follow logs in real time:

```
docker compose -f srcs/docker-compose.yml logs -f
```

To stop the infrastructure:

```
make down
```

or

```
docker compose -f srcs/docker-compose.yml down
```

To remove containers and volumes:

```
docker compose -f srcs/docker-compose.yml down -v
```

To list Docker volumes:

```
docker volume ls
```

To inspect a specific volume:

```
docker volume inspect <volume_name>
```

---

## Identify where the project data is stored and how it persists

The project uses Docker volumes to store persistent data.

Important data directories inside containers include:

MariaDB database files:

```
/var/lib/mysql
```

WordPress website files:

```
/var/www/html
```

These directories are mounted to Docker volumes defined in the `docker-compose.yml` file.

Using volumes ensures that data is preserved even if containers are restarted or rebuilt.

To see the existing volumes:

```
docker volume ls
```

To inspect where a volume is stored on the host system:

```
docker volume inspect <volume_name>
```

As long as volumes are not removed, the database and WordPress files will remain available across container restarts.