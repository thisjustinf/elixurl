#!/bin/sh
# docker-entrypoint.sh

# Exit immediately if a command exits with a non-zero status.
set -e

ENVIRONMENT=${ENVIRONMENT:=dev}

# Source the environment file. Adjust the path if needed.
if [ -f "/app/env/.env.$ENVIRONMENT" ]; then
    echo "Loading environment variables from /app/env/.env.$ENVIRONMENT"
    . /app/env/.env.${ENVIRONMENT}
fi

# Optional: If your container is started with command line flags (i.e. if first argument starts with a '-'),
# prepend "mix phx.server" as the command.
if [ "${1#-}" != "$1" ]; then
    set -- mix phx.server "$@"
fi

# Optionally, if you want to detect a "mix phx.server" command and run migrations before starting:
if [ "$1" = "mix" ] && [ "$2" = "phx.server" ]; then
    echo "Running database migrations..."
    mix ecto.setup
fi

# Execute the command passed into the docker run invocation.
exec "$@"
