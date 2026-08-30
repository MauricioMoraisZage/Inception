# Secrets

This directory contains local secret files required by the Docker Compose stack.

The real `.txt` files are intentionally excluded from Git.

Create the following files locally:

- `db_root_password.txt`
- `db_password.txt`
- `credentials.txt`
- `wp_user_password.txt`

Each file should contain only the corresponding secret value.

Never commit real credentials or passwords to the repository.
