# User documentation

This document explains, in simple terms, how an end user or administrator can understand, start, access, and check this project.

## Services provided by the stack

This project runs a small web infrastructure using Docker containers. The stack includes three main services:

- **NGINX** – handles HTTPS connections and serves as the public entry point.
- **WordPress** – provides the website and the administration interface.
- **MariaDB** – stores the website data used by WordPress.

These services interact like this:

Browser → NGINX → WordPress → MariaDB

The browser connects to NGINX, NGINX forwards PHP requests to WordPress, and WordPress stores or retrieves data from MariaDB.

---

## Start and stop the project

To start the project, go to the root of the repository and run:

```
make
```

This command builds the images if necessary and starts the containers.

To check whether the containers are running:

```
docker ps
```

To stop the project:

```
make down
```

You can also stop it with Docker Compose:

```
docker compose -f srcs/docker-compose.yml down
```

---

## Access the website and the administration panel

After the project is running, open the website in your browser:

```
https://<your-login>.42.fr
```

Example:

```
https://mamorais.42.fr
```

If the domain does not work, add it to your system hosts file so it points to your local machine:

```
127.0.0.1 <your-login>.42.fr
```

The WordPress administration panel is available at:

```
https://<your-login>.42.fr/wp-login
```

Use the administrator username and password created for the project.

---

## Locate and manage credentials

Project credentials are stored locally and should not be exposed publicly.

Non-sensitive configuration is usually stored in:

```
srcs/.env
```

Sensitive values such as passwords are stored in secret files, for example:

```
secrets/db_password.txt
secrets/db_root_password.txt
secrets/credentials.txt
secrets/wp_user_password.txt
```

If you change any credential, restart the project so the containers can use the updated values.

---

## Check that the services are running correctly

First, verify that all containers are active:

```
docker ps
```

You should see these services running:

- nginx
- wordpress
- mariadb

You can also check logs to confirm there are no errors:

```
docker compose -f srcs/docker-compose.yml logs
```

To test the NGINX configuration:

```
docker exec -it nginx nginx -t
```

To confirm that the website is reachable, open:

```
https://<your-login>.42.fr
```

If the homepage loads and the WordPress admin panel is accessible, the stack is working correctly.
